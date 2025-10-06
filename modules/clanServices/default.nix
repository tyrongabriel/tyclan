{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;

  module_definitions = {
    "@tyclan/roster" = import ./roster;
    "@tyclan/k3s" = import ./k3s; # To give config access
    "@tyclan/tailscale" = ./tailscale; # To give config access
    "@tyclan/tailscale-traefik" = ./tailscale-traefik; # To give config access
    #"module-name" = import ./module-name;

  };
in
lib.foldr lib.recursiveUpdate { } [ module_definitions ]
