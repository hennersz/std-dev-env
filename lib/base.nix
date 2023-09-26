mkShell:{ 
  pkgs,
  inputs,
  scripts? {},
  packages? [],
  certificates? [],
  containers? {},
  devcontainer? {},
  devenv? {},
  difftastic? {},
  enterShell? "",
  env? {},
  hosts? {},
  hostsProfileName? "",
  infoSections? {},
  languages? {},
  pre-commit? {},
  process? {},
  process-managers? {},
  processes? {},
  services? {},
  starship? {},
  modules? []}:
let
  stdScripts = {
    tests.exec = "echo tests not implemented; exit 1";
    lint.exec = "echo lint not implemented; exit 1";
    check.exec = ''
    lint
    tests
    '';
    up.exec = "devenv up";
    clean.exec = "echo clean not implemented; exit 1";
    upgrade.exec = "nix flake update";
  };
in
mkShell {
  inherit pkgs inputs;
  modules = [
    ({pkgs, ...}: {
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
        pre-commit
        process
        process-managers
        processes
        services
        starship
        ;
      scripts = stdScripts // scripts;
    })
  ] ++ modules ;
}