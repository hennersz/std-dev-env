{ devenv }:
let
  inherit (devenv.lib) mkShell;
in
{
  base = import ./base.nix mkShell;
}
