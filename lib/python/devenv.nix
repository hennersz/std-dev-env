{ base, poetry2nix }: { pkgs
                      , inputs
                      , self
                      , scripts ? { }
                      , packages ? [ ]
                      , certificates ? [ ]
                      , containers ? { }
                      , devcontainer ? { }
                      , devenv ? { }
                      , difftastic ? { }
                      , enterShell ? ""
                      , env ? { }
                      , hosts ? { }
                      , hostsProfileName ? ""
                      , infoSections ? { }
                      , languages ? { }
                      , pre-commit ? { }
                      , process ? { }
                      , process-managers ? { }
                      , processes ? { }
                      , services ? { }
                      , starship ? { }
                      , modules ? [ ]
                      }:
let
  inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryEnv;
  pythonEnv = mkPoetryEnv { projectDir = self; };
  pythonPkgs = with pkgs; [
    poetry
    pythonEnv
  ];

  pythonScripts = {
    upgrade-python.exec = ''
      poetry update
    '';
    upgrade.exec = ''
      upgrade-nix
      upgrade-python
    '';
    lint.exec = ''
      flake8
    '';
    tests.exec = "pytest";
  };
in
base {
  inherit
    pkgs
    inputs
    certificates
    containers
    devcontainer
    devenv
    difftastic
    enterShell
    env
    hosts
    hostsProfileName
    infoSections
    languages
    pre-commit
    process
    process-managers
    processes
    services
    starship
    ;
  packages = packages ++ pythonPkgs;
  scripts = pythonScripts // scripts;
}
