{ nix, readScripts }:
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
  tofuPkgs = with pkgs; [
    opentofu
    tflint
    tfsec
  ];
  tofuScripts = readScripts { dir = ./scripts; };
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
  packages = packages ++ tofuPkgs;
  scripts = tofuScripts // scripts;
}
