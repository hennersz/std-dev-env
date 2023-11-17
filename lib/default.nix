{ devenv, poetry2nix }:
let
  inherit (devenv.lib) mkShell;
in
rec {
  base = import ./base.nix mkShell;
  nix = import ./nix.nix base;
  python = import ./python { inherit base poetry2nix; };
}
