# std-dev-env

A Nix flake library that provides standardised development shells on top of
[`pkgs.mkShell`](https://nixos.org/manual/nixpkgs/stable/#sec-pkgs-mkShell) and
[`cachix/git-hooks.nix`](https://github.com/cachix/git-hooks.nix), so that the
developer experience of formatting, linting, testing and running a project is
largely the same regardless of the language or framework.

It exposes per-language builders (`base`, `nix`, `python`, `tofu`) and a set of
project templates.

## Pure evaluation (no `--impure`)

Shells build on plain `pkgs.mkShell`, so consuming flakes evaluate **purely**.
Do **not** pass `--impure` / `--no-pure-eval` when entering a shell:

```sh
nix develop        # not: nix develop --impure
```

```
# .envrc
use flake          # not: use flake --impure
```

> Previous versions wrapped `cachix/devenv`, which read the project root via
> `builtins.getEnv` at evaluation time and therefore required `--impure`. That
> dependency has been removed.

## `PROJECT_ROOT`

The dev shell exports `PROJECT_ROOT` at shell entry (this replaces the old
devenv `DEVENV_ROOT`). It resolves to the git top-level, falling back to the
current directory:

```sh
export PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"
```

Scripts that need the project root read `$PROJECT_ROOT`.

## Usage

Pick a template:

```sh
nix flake init -t github:hennersz/std-dev-env#nix     # or: base, python, tofu
```

Or call a builder directly from your own flake:

```nix
devShells.default = std-dev-env.lib.nix.devenv {
  inherit pkgs inputs;
};
```

The builder entry points are named `.devenv` for backwards compatibility:

```nix
std-dev-env.lib.base.devenv
std-dev-env.lib.nix.devenv
std-dev-env.lib.python.devenv
std-dev-env.lib.tofu.devenv
```

These are now `pkgs.mkShell`-backed; the `.devenv` name is retained only as a
compatibility alias and no longer implies a dependency on the devenv project.

### Supported arguments

| Argument            | Description                                                        |
| ------------------- | ------------------------------------------------------------------ |
| `pkgs`              | nixpkgs package set for the target system (required)               |
| `packages`          | extra packages added to the shell                                  |
| `nativeBuildInputs` | passed through to `pkgs.mkShell`                                   |
| `scripts`           | `{ <name>.exec = "..."; }`, turned into real executables on `PATH` |
| `enterShell`        | shell script appended to the generated `shellHook`                 |
| `shellHook`         | additional shell script appended after `enterShell`                |
| `env`               | attrset exported as environment variables at shell entry           |
| `git-hooks`         | extra `git-hooks.nix` hooks, merged into the default `check` hook  |
| `tasks`             | minimal devenv shell-entry task compatibility (see below)          |
| `inputs`            | retained for backwards compatibility; currently unused             |
| `self`              | required by `python.devenv` for the poetry2nix `projectDir`        |

Passing an unsupported devenv option raises a Nix evaluation error rather than
being silently ignored.

### Pre-commit hook

A single `check` pre-commit hook is wired via `git-hooks.nix`. It runs the
`check` script and is never handed filenames (`pass_filenames = false`). The
hook is installed **at shell entry** (not by any imperative command), so
commit inside the dev shell for it to run.

Hooks are installed with [`prek`](https://github.com/j178/prek) — a faster,
drop-in `pre-commit` replacement — by default. Override the runner (or add
hooks) via the `git-hooks` argument:

```nix
git-hooks = {
  package = pkgs.pre-commit;   # opt back into upstream pre-commit
  hooks = { /* extra git-hooks.nix hooks */ };
};
```

`git-hooks.nix` writes a generated `.pre-commit-config.yaml`; this file is
gitignored (both here and in the templates).

### Shell-entry tasks (devenv compatibility)

A minimal subset of devenv tasks is supported: tasks whose `before` list
contains `"devenv:enterShell"` run at shell entry, from `$PROJECT_ROOT`, before
any caller-provided `enterShell`.

```nix
tasks."node:install" = {
  exec = ''
    npm install
  '';
  before = [ "devenv:enterShell" ];
};
```

No other devenv task-graph behaviour is supported (`after` hooks, status
checks, arbitrary targets, process orchestration).

## Unsupported devenv features

Because the shells are plain `pkgs.mkShell`, the following devenv features are
**not** available:

```
services            processes           process
containers          devcontainer        languages
starship            difftastic          hosts / hostsProfileName
certificates        modules             infoSections
full task graph     devenv up
```

The `up` script now prints an error and exits non-zero; use a project-specific
process runner or service manager instead.

## `cacheRoots`

`packages.cacheRoots` produces a GC-root script (via
`nix-community/cache-nix-action`) covering the dev shell closure and selected
flake inputs, so CI (e.g. GitHub Actions) can cache `/nix/store` between runs.
It evaluates purely — no `--impure` required:

```sh
nix build .#cacheRoots
nix profile add .#cacheRoots
```
