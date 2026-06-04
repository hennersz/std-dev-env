{ nix, poetry2nix, readScripts }: { pkgs
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
                                  , tasks ? { }
                                  , modules ? [ ]
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
    tasks
    modules
    ;
  packages = packages ++ pythonPkgs;
  scripts = pythonScripts // scripts;
}
