{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;

  module_definitions = {
    "@tyclan/roster" = import ./roster;
    "@tyclan/k3s" = ./k3s; # To give config access
    #"module-name" = import ./module-name;

  };
in
lib.foldr lib.recursiveUpdate { } [ module_definitions ]
