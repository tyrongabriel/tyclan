{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;

  module_definitions = {
    "@tyclan/roster" = import ./roster;
    "@tyclan/k3s" = import ./k3s; # To give config access
    "@tyclan/k3s-new" = import ./k3s-new; # To give config access
    "@tyclan/tailscale" = ./tailscale;
    "@tyclan/tailscale-traefik" = ./tailscale-traefik;
    "@tyclan/netbird" = ./netbird;
    "@tyclan/desktop" = ./desktop;
    "@tyclan/stylix" = ./stylix;
    "@tyclan/hytale-server" = ./hytale-server;
    "@tyclan/ollama" = ./ollama;
    "@tyclan/llama-cpp" = ./llama-cpp;
    "@tyclan/authentik" = ./authentik;
    #"module-name" = import ./module-name;

  };
in
lib.foldr lib.recursiveUpdate { } [ module_definitions ]
