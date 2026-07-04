{ poetry2nix, cache-nix-action, git-hooks }:
rec {
  readScripts = import ./readScripts.nix;
  cacheRoots = import ./cacheRoots.nix { inherit cache-nix-action; };
  # `preCommitHooks` is the git-hooks.nix flake input. It is named distinctly
  # from the caller-facing `git-hooks` argument accepted by the shell builders
  # to avoid the two shadowing each other inside the builder.
  base = import ./base { inherit readScripts; preCommitHooks = git-hooks; };
  nix = import ./nix { inherit readScripts base; };
  python = import ./python { inherit nix poetry2nix readScripts; };
  tofu = import ./tofu { inherit nix readScripts; };
}
