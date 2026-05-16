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
                                  , modules ? [ ]
                                  }:
let
  inherit (poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryEnv;
  pythonEnv = mkPoetryEnv { projectDir = self; };
  pythonPkgs = with pkgs; [
    poetry
    pythonEnv
  ];
  pythonScripts = readScripts ./scripts;
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
    modules
    ;
  packages = packages ++ pythonPkgs;
  scripts = pythonScripts // scripts;
}
