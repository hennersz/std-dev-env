{
  inputs = {
    devenv.url = "github:cachix/devenv";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cache-nix-action = {
      url = "github:nix-community/cache-nix-action/v7";
      flake = false;
    };
  };

  description = ''
    A nix flake that wraps devenv with a standardised
    set of commands so the dx of testing and running a 
    project is largely the same regardless of the language
    or framework you are using.
  '';

  outputs = { self, nixpkgs, flake-utils, devenv, poetry2nix, cache-nix-action, ... }@inputs:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };

          tasks = self.lib.readScripts { dir = ./scripts; };
          testScripts = self.lib.readScripts { dir = ./tests; prefix = "test-"; };
          scripts = tasks // testScripts;

          devShells.default = self.lib.nix.devenv { 
            inherit pkgs inputs scripts; 
            packages = with pkgs; [ poetry ]; 
          };
          saveFromGC =
            (import "${cache-nix-action}/saveFromGC.nix" {
              inherit pkgs inputs;
              inputsInclude = [
                "nixpkgs"
                "flake-utils"
                "devenv"
                "poetry2nix"
              ];
              derivations = [ devShells.default ];
            }).package;
        in
        {
          inherit devShells;
          packages.saveFromGC = saveFromGC;
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
