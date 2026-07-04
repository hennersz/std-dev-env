# Resolve a devenv-style task dependency graph into an ordered shell-entry
# script.
#
# Each task is `{ exec, before ? [ ], after ? [ ], status ? null }`:
#   exec    - shell command to run (required)
#   before  - task / lifecycle names this task must run BEFORE
#   after   - task / lifecycle names this task must run AFTER
#   status  - optional shell command; if it succeeds the task is skipped
#
# The virtual node "devenv:enterShell" represents shell entry. Every task that
# must (transitively, via `before`/`after`) run before "devenv:enterShell" is
# executed at shell entry in dependency order, each from $PROJECT_ROOT.
#
# The full before/after graph is honoured: a task pulled in as a dependency of
# a shell-entry task runs too, in the correct order. Cycles are a Nix
# evaluation error. Tasks not connected to "devenv:enterShell" are not run
# (there is no task-runner CLI; only the shell-entry lifecycle exists).
{ lib, tasks }:
let
  enterShell = "devenv:enterShell";

  taskNames = builtins.attrNames tasks;

  supportedFields = [ "exec" "before" "after" "status" ];

  # Task names are namespaced like devenv: `<namespace>:<name>` (one or more
  # `:`-separated, non-empty segments), e.g. "node:install". The virtual
  # lifecycle hooks live in the `devenv:` namespace (e.g. "devenv:enterShell").
  isNamespaced = name:
    let parts = lib.splitString ":" name;
    in (builtins.length parts >= 2) && (lib.all (p: p != "") parts);

  # A reference is valid if it names a known task or a devenv lifecycle hook.
  knownRef = ref: (builtins.elem ref taskNames) || (lib.hasPrefix "devenv:" ref);

  # Validate task shape: enforce namespaced names, reject unsupported fields
  # (rather than silently ignoring them) and catch typos in before/after refs.
  assertTask = name: task:
    let
      badFields = lib.subtractLists supportedFields (builtins.attrNames task);
      refs = (task.before or [ ]) ++ (task.after or [ ]);
      badRefs = lib.filter (r: !(knownRef r)) refs;
    in
    if !(isNamespaced name) then
      throw "std-dev-env: task name '${name}' must be namespaced as '<namespace>:<name>' (e.g. \"node:install\")."
    else if badFields != [ ] then
      throw "std-dev-env: task '${name}' has unsupported field(s): ${lib.concatStringsSep ", " badFields}. Supported: ${lib.concatStringsSep ", " supportedFields}."
    else if !(task ? exec) then
      throw "std-dev-env: task '${name}' is missing required 'exec'."
    else if badRefs != [ ] then
      throw "std-dev-env: task '${name}' references unknown task(s): ${lib.concatStringsSep ", " badRefs}."
    else task;

  validated = lib.mapAttrs assertTask tasks;

  # Directed edges: { from; to } means `from` must run before `to`.
  #   before = [ x ]  ->  this -> x
  #   after  = [ y ]  ->  y -> this
  edges = lib.concatMap
    (name:
      (map (to: { from = name; inherit to; }) (validated.${name}.before or [ ]))
      ++ (map (from: { inherit from; to = name; }) (validated.${name}.after or [ ]))
    )
    taskNames;

  parentsOf = node: lib.unique (map (e: e.from) (lib.filter (e: e.to == node) edges));

  # All nodes that can reach `target` by following edges (i.e. must run before
  # it). Terminates on cycles because visited nodes are never revisited.
  ancestorsOf = target:
    let
      go = visited: frontier:
        if frontier == [ ] then visited
        else
          let
            next = lib.unique (lib.concatMap parentsOf frontier);
            fresh = lib.filter (n: !(builtins.elem n visited)) next;
          in
          go (visited ++ fresh) fresh;
    in
    go [ ] [ target ];

  # Tasks (real, `exec`-bearing nodes) that must run before shell entry.
  requiredTaskNames = lib.filter (n: builtins.elem n taskNames) (ancestorsOf enterShell);

  subEdges = lib.filter
    (e: builtins.elem e.from requiredTaskNames && builtins.elem e.to requiredTaskNames)
    edges;

  # Kahn's algorithm. Ties broken alphabetically for stable output.
  topoSort = nodes:
    let
      go = remaining: acc:
        if remaining == [ ] then acc
        else
          let
            hasIncoming = n: lib.any (e: e.to == n && builtins.elem e.from remaining) subEdges;
            ready = lib.sort (a: b: a < b) (lib.filter (n: !(hasIncoming n)) remaining);
          in
          if ready == [ ] then
            throw "std-dev-env: cycle detected in task graph among: ${lib.concatStringsSep ", " remaining}."
          else
            go (lib.subtractLists ready remaining) (acc ++ ready);
    in
    go nodes [ ];

  ordered = topoSort requiredTaskNames;

  taskScript = name:
    let
      task = validated.${name};
      status = task.status or null;
      run = ''
        echo "std-dev-env: running task '${name}'" >&2
        (
          cd "$PROJECT_ROOT"
          ${task.exec}
        )
      '';
    in
    if status == null then run
    else ''
      if ( cd "$PROJECT_ROOT" && ${status} ); then
        echo "std-dev-env: skipping task '${name}' (status satisfied)" >&2
      else
      ${run}
      fi
    '';
in
lib.concatStringsSep "\n" (map taskScript ordered)
