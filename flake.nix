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
        {
          devShells.default = self.lib.nix { inherit pkgs inputs; packages = with pkgs; [ poetry ]; };
        }) // {
      templates = {
        base = {
          description = "basic development environment with no preinstalled tools";
          path = ./templates/base;
        };
        python = {
          description = "basic development environment for python using poetry";
          path = ./templates/python;
        };
      };

      lib = import ./lib { inherit devenv poetry2nix; };
    };
}
