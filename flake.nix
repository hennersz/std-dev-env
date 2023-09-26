{
  inputs = {
    devenv.url = "github:cachix/devenv/v0.6.3";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  description = ''
    A nix flake that wraps devenv with a standardised
    set of commands so the dx of testing and running a 
    project is largely the same regardless of the language
    or framework you are using.
  '';

  outputs = { self, nixpkgs, flake-utils, devenv, ... }@inputs:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        {
          devShells.default = self.lib.base {
            inherit pkgs inputs;
            packages = with pkgs; [
              nixVersions.nix_2_17
              statix
              nil
              nixpkgs-fmt
            ];
            scripts.lint.exec = ''
              statix check $DEVENV_ROOT
              nixpkgs-fmt --check ./**/*.nix
            '';
            scripts.format.exec = "nixpkgs-fmt ./**/*.nix";
          };
        }) // {
      templates = {
        base = {
          description = "basic development environment with no preinstalled tools";
          path = ./templates/base;
        };
      };

      lib = import ./lib { inherit devenv; };
    };
}
