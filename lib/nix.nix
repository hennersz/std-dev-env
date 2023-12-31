base: { pkgs
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
      , pre-commit ? { }
      , process ? { }
      , process-managers ? { }
      , processes ? { }
      , services ? { }
      , starship ? { }
      , modules ? [ ]
      }:
let
  nixScripts = {
    lint.exec = ''
      shopt -s globstar
      statix check "$DEVENV_ROOT"
      nixpkgs-fmt --check "$DEVENV_ROOT"/**/*.nix
    '';
    format.exec = ''
      shopt -s globstar
      nixpkgs-fmt "$DEVENV_ROOT"/**/*.nix
    '';
  };

  nixPkgs = with pkgs; [
    nixVersions.nix_2_17
    statix
    nil
    nixpkgs-fmt
  ];
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
  packages = packages ++ nixPkgs;
  scripts = nixScripts // scripts;
}
