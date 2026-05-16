{
  inputs = {
    std-dev-env.url = "github:hennersz/std-dev-env";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    cache-nix-action = {
      url = "github:nix-community/cache-nix-action/v7";
      flake = false;
    };
  };

  outputs = { self, std-dev-env, nixpkgs, flake-utils, cache-nix-action, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        devShells.default = std-dev-env.lib.base.devenv {
          inherit pkgs inputs;
        };

        saveFromGC =
          (import "${cache-nix-action}/saveFromGC.nix" {
            inherit pkgs inputs;
            inputsInclude = [
              "nixpkgs"
              "flake-utils"
              "std-dev-env"
            ];
            derivations = [ devShells.default ];
          }).package;
      in
      {
        inherit devShells;
        packages.saveFromGC = saveFromGC;
      });
}
