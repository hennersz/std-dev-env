{
  inputs = {
    devenv.url = "github:cachix/devenv/v0.6.3";
  };
  description = ''
    A nix flake that wraps devenv with a standardised
    set of commands so the dx of testing and running a 
    project is largely the same regardless of the language
    or framework you are using.
  '';

  outputs = { devenv, ... }@inputs: 
  {
    templates = {
      base = {
        description = "basic development environment with no preinstalled tools";
        path = ./templates/base;
      };
    };

    lib = import ./lib { inherit devenv; };
  };
}
