{ base, readScripts }:
{
  devenv = import ./devenv.nix { inherit readScripts base; };
}
