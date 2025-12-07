{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;

  module_definitions = {
    "@tyclan/roster" = import ./roster;
    "@tyclan/k3s" = import ./k3s; # To give config access
    "@tyclan/tailscale" = ./tailscale;
    "@tyclan/tailscale-traefik" = ./tailscale-traefik;
    "@tyclan/netbird" = ./netbird;
    "@tyclan/desktop" = ./desktop;
    "@tyclan/stylix" = ./stylix;
    #"module-name" = import ./module-name;

  };
in
lib.foldr lib.recursiveUpdate { } [ module_definitions ]
