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

        devShells.default = std-dev-env.lib.base.devenv {
          inherit pkgs inputs;
        };

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
        packages.cacheRoots = cacheRoots;
      });
}
