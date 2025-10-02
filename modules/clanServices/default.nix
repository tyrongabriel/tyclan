{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;

  module_definitions = {
    "@tyclan/roster" = import ./roster;
    "@tyclan/k3s" = import ./k3s;
    #"module-name" = import ./module-name;

  };
in
lib.foldr lib.recursiveUpdate { } [ module_definitions ]
