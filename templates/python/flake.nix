{
  inputs = {
    std-dev-env.url = "github:hennersz/std-dev-env";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, std-dev-env, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        inherit (std-dev-env.lib.python.mkPoetry2Nix pkgs) mkPoetryApplication;

        devShells.default = std-dev-env.lib.python.devenv {
          inherit pkgs inputs self;
        };

        defaultPackage = mkPoetryApplication { projectDir = self; };

        cacheRoots = std-dev-env.lib.cacheRoots {
          inherit pkgs inputs;
          inputsInclude = [
            "nixpkgs"
            "flake-utils"
            "std-dev-env"
          ];
          derivations = [ devShells.default ];
        };
      in
      {
        inherit devShells;
        packages = {
          default = defaultPackage;
          inherit cacheRoots;
        };
      });
}
