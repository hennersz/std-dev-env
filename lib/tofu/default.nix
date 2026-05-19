{ nix, readScripts }:
{
  devenv = import ./devenv.nix { inherit nix readScripts; };
}
