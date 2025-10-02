{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;

  services = {
    internet = import ./internet.nix { inherit inputs; };
    zerotier = import ./zerotier.nix {
      inherit inputs;
      inherit lib;
    };
    k3s = import ./k3s.nix { inherit inputs; };
  };
in
lib.foldr lib.recursiveUpdate { } (lib.attrValues services)
