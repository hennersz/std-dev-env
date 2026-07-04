{ readScripts, base }:
{ pkgs
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
  nixScripts = readScripts { dir = ./scripts; };

  nixPkgs = with pkgs; [
    nix
    statix
    nil
    nixpkgs-fmt
    shellcheck
    shfmt
  ];
in
base.devenv {
  inherit
    pkgs
    inputs
    nativeBuildInputs
    shellHook
    env
    git-hooks
    tasks
    ;
  packages = packages ++ nixPkgs;
  scripts = nixScripts // scripts;

  # Nix breaks if this is set as it can't find shared libraries
  enterShell = ''
    unset LD_LIBRARY_PATH
  '' + enterShell;
}
