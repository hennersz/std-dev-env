{ nix, poetry2nix, readScripts }:
{ pkgs
, self
, inputs ? { }
, scripts ? { }
, packages ? [ ]
, nativeBuildInputs ? [ ]
, enterShell ? ""
, shellHook ? ""
, env ? { }
, git-hooks ? { }
, tasks ? { }
}:
let
  inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryEnv;
  pythonEnv = mkPoetryEnv {
    projectDir = self;
    groups = [ "main" ];
    checkGroups = [ ];
  };
  pythonPkgs = with pkgs; [
    poetry
    pythonEnv
    python3Packages.ruff
    python3Packages.pytest
  ];
  pythonScripts = readScripts { dir = ./scripts; };
in
nix.devenv {
  inherit
    pkgs
    inputs
    enterShell
    shellHook
    env
    git-hooks
    tasks
    nativeBuildInputs
    ;
  packages = packages ++ pythonPkgs;
  scripts = pythonScripts // scripts;
}
