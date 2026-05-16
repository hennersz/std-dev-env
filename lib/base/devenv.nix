{ readScripts, mkShell }: { pkgs
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
  stdScripts = readScripts ./scripts;
in
mkShell {
  inherit pkgs inputs;
  modules = [
    ({ pkgs, ... }: {
      inherit
        packages
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
        ;
      scripts = stdScripts // scripts;
    })
  ] ++ modules;
}
