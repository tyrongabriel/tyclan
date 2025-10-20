{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;

  # Import modules
  core = import ./core {
    inherit inputs;
  }; # Clan Config
  services = import ./services { inherit inputs; }; # Clan service instances
  tags = import ./tags { inherit inputs; };

  inventory = {
    inherit (core) machines;
    instances = lib.recursiveUpdate (lib.recursiveUpdate core.instances services.instances) tags.instances;
    #instances = lib.recursiveUpdate core.instances services.instances;
  };
in
inventory
