{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;

  module_definitions = {
    "@tyclan/roster" = import ./roster;
    "@tyclan/k3s" = import ./k3s; # To give config access
    "@tyclan/tailscale" = ./tailscale;
    "@tyclan/tailscale-traefik" = ./tailscale-traefik;
    "@tyclan/netbird" = ./netbird;
    #"module-name" = import ./module-name;

  };
in
lib.foldr lib.recursiveUpdate { } [ module_definitions ]
