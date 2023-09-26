{ devenv }: 
let
  mkShell = devenv.lib.mkShell;
in
{
  base = import ./base.nix mkShell;
}