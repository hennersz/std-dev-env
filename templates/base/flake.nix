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
      in
      {
        devShells.default = std-dev-env.lib.base {
          inherit pkgs inputs;
        };
      });
}
