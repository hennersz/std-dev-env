{ readScripts, preCommitHooks }:
{
  devenv = import ./devenv.nix { inherit readScripts preCommitHooks; };
}
