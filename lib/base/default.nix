{ mkShell, readScripts }:
{
  devenv = import ./devenv.nix { inherit readScripts mkShell; };
}
