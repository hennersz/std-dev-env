{ base, poetry2nix }:
{
  devenv = import ./devenv.nix { inherit base poetry2nix; };
  mkPoetry2Nix = import ./mkPoetry2Nix.nix poetry2nix;
}
