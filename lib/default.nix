{ devenv }:
let
  inherit (devenv.lib) mkShell;
in
rec {
  base = import ./base.nix mkShell;
  nix = import ./nix.nix base;
}
