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
                          , tasks ? { }
                          , modules ? [ ]
                          }:
let
  stdScripts = readScripts { dir = ./scripts; };
  stdGitHooks = {
    enable = true;
    hooks = {
      pre-commit = {
        enable = true;
        name = "check";
        entry = "check";
        pass_filenames = false;
      };
    };
  };
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
        process
        processes
        services
        starship
        tasks
        ;
      scripts = stdScripts // scripts;
      git-hooks = stdGitHooks // git-hooks;
    })
  ] ++ modules;
}
