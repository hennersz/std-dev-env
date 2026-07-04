{ cache-nix-action }:
{ pkgs, inputs, inputsInclude ? [ ], derivations ? [ ] }:
(import "${cache-nix-action}/saveFromGC.nix" {
  inherit pkgs inputs inputsInclude derivations;
}).package
