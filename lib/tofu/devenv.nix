{ nix, readScripts }: { pkgs
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
                      , modules ? [ ]
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
  packages = packages ++ tofuPkgs;
  scripts = tofuScripts // scripts;
}
