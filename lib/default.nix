{ devenv, poetry2nix }:
let
  inherit (devenv.lib) mkShell;
in
rec {
  readScripts = import ./readScripts.nix;
  base = import ./base { inherit readScripts mkShell; };
  nix = import ./nix { inherit readScripts base; };
  python = import ./python { inherit nix poetry2nix readScripts; };
  tofu = import ./tofu { inherit nix readScripts; };
}
