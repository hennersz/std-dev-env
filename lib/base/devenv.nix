# Base dev-shell builder.
#
# Historically this wrapped `devenv.lib.mkShell`, which required `--impure`
# because devenv reads the project root via `builtins.getEnv` at evaluation
# time. This implementation is built on plain `pkgs.mkShell` plus
# `cachix/git-hooks.nix`, so consuming flakes evaluate purely (no `--impure`).
#
# The name `devenv` is retained only as a backwards-compatibility alias for
# downstream callers such as `std-dev-env.lib.nix.devenv`.
#
# Supported arguments:
#   pkgs             - the nixpkgs package set for the target system (required)
#   inputs           - retained for backwards compatibility; currently unused
#   packages         - extra packages added to the shell
#   nativeBuildInputs - passed through to pkgs.mkShell
#   scripts          - { <name>.exec = "..."; } turned into real executables
#   enterShell       - shell script appended to the generated shellHook
#   shellHook        - additional shell script appended after enterShell
#   env              - attrset exported as environment variables at shell entry
#   git-hooks        - { hooks = ...; package = ...; }: extra git-hooks.nix
#                      hooks merged into the default `check`, and an optional
#                      pre-commit package override (defaults to pkgs.prek)
#   tasks            - devenv-style task graph run at shell entry (see ../tasks.nix)
#
# Unsupported devenv options (containers, devcontainer, services, processes,
# process, languages, starship, difftastic, hosts, hostsProfileName,
# certificates, modules, infoSections, ...) are intentionally NOT accepted:
# passing them raises a Nix evaluation error rather than being silently
# ignored.
{ readScripts, preCommitHooks }:
{ pkgs
, inputs ? { }
, scripts ? { }
, packages ? [ ]
, nativeBuildInputs ? [ ]
, enterShell ? ""
, shellHook ? ""
, env ? { }
, git-hooks ? { }
, tasks ? { }
}:
let
  inherit (pkgs) lib;

  stdScripts = readScripts { dir = ./scripts; };
  allScripts = stdScripts // scripts;

  # Turn `{ <name>.exec = "..."; }` script definitions into real executables so
  # they land on PATH inside the shell (devenv used to do this via its own
  # scripts module).
  scriptPackages = lib.mapAttrsToList
    (name: script: pkgs.writeShellScriptBin name script.exec)
    allScripts;

  # Reproduce the single devenv `check` pre-commit hook: it runs the `check`
  # script and is never handed filenames.
  checkHook = lib.optionalAttrs (allScripts ? check) {
    check = {
      enable = true;
      name = "check";
      entry = "${pkgs.writeShellScriptBin "check" allScripts.check.exec}/bin/check";
      pass_filenames = false;
    };
  };

  # Install hooks with `prek` (a faster, drop-in pre-commit replacement) by
  # default rather than upstream `pre-commit`. git-hooks.nix has first-class
  # prek support and, crucially, this makes shell entry install prek's own git
  # shim so it does not clash with a prek-based workflow. Overridable via
  # `git-hooks.package`.
  preCommitCheck = preCommitHooks.lib.${pkgs.system}.run {
    src = ./.;
    package = git-hooks.package or pkgs.prek;
    hooks = checkHook // (git-hooks.hooks or { });
  };

  # Export caller-provided environment variables at shell entry.
  envExports = lib.concatStringsSep "\n"
    (lib.mapAttrsToList
      (name: value: "export ${name}=${lib.escapeShellArg (toString value)}")
      env);

  # devenv-style task graph: resolve the full before/after dependency graph and
  # run, at shell entry (from the project root, before any caller `enterShell`),
  # every task that must run before "devenv:enterShell". See ../tasks.nix.
  shellEntryTasks = import ../tasks.nix { inherit lib tasks; };
in
pkgs.mkShell {
  packages = packages ++ scriptPackages;
  nativeBuildInputs = nativeBuildInputs ++ preCommitCheck.enabledPackages;

  # Everything here runs at shell entry (runtime), so it is pure with respect
  # to flake evaluation. Order matters:
  #   1. export PROJECT_ROOT (replaces devenv's DEVENV_ROOT)
  #   2. export caller env vars
  #   3. run shell-entry tasks (before enterShell, from the project root)
  #   4. install the git-hooks.nix pre-commit hook
  #   5. caller enterShell
  #   6. caller shellHook
  shellHook = ''
    export PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"

    ${envExports}

    ${shellEntryTasks}

    ${preCommitCheck.shellHook}

    ${enterShell}

    ${shellHook}
  '';
}
