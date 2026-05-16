{
  inputs = {
    devenv.url = "github:cachix/devenv";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  description = ''
    A nix flake that wraps devenv with a standardised
    set of commands so the dx of testing and running a 
    project is largely the same regardless of the language
    or framework you are using.
  '';

  outputs = { self, nixpkgs, flake-utils, devenv, poetry2nix, ... }@inputs:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        let
          templatesTest = pkgs.runCommand "std-dev-env-templates-test" {
            nativeBuildInputs = [ pkgs.nix ];
          } ''
            export REPO_ROOT=${./.}
            ${pkgs.bash}/bin/bash ${./tests/templates.sh}
            touch $out
          '';
        in
        {
          devShells.default = self.lib.nix.devenv { inherit pkgs inputs; packages = with pkgs; [ poetry ]; };
          checks.templates = templatesTest;
        }) // {
      templates = {
        base = {
          description = "basic development environment with no preinstalled tools";
          path = ./templates/base;
        };
        nix = {
          description = "development environment for nix projects";
          path = ./templates/nix;
        };
        python = {
          description = "basic development environment for python using poetry";
          path = ./templates/python;
        };
      };

      lib = import ./lib { inherit devenv poetry2nix; };
    };
}
