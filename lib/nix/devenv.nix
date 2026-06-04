{ readScripts, base }: { pkgs
                       , inputs
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
    certificates
    containers
    devcontainer
    devenv
    difftastic
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
  packages = packages ++ nixPkgs;
  scripts = nixScripts // scripts;

  # Nix breaks if this is set as it can't find shared libraries
  enterShell = ''
    unset LD_LIBRARY_PATH 
  '' + enterShell;
}
