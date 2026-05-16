{ nix, poetry2nix }: { pkgs
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
                      , git-hooks ? { }
                      , process ? { }
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
      ruff check
    '';
    format.exec = ''
      ruff format
    '';
    tests.exec = "pytest";
  };
in
nix {
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
    git-hooks
    process
    processes
    services
    starship
    modules
    ;
  packages = packages ++ pythonPkgs;
  scripts = pythonScripts // scripts;
}
