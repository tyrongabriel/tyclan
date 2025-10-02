{
  outputs =
    { ... }:
    let
      templates = {
        disko = {
          uefi-8g-swap = {
            description = "A simple disk with UEFI boot and 8GB swap";
            path = ./disk/uefi-8g-single-disk;
          };
        };

        # machine = {
        #   flash-installer = {
        #     description = "Initialize a new flash-installer machine";
        #     path = ./machine/flash-installer;
        #   };

        #   new-machine = {
        #     description = "Initialize a new machine";
        #     path = ./machine/new-machine;
        #   };
        # };

        # clan = {
        #   default = {
        #     description = "Initialize a new clan flake";
        #     path = ./clan/default;
        #   };
        #   minimal = {
        #     description = "for clans managed via (G)UI";
        #     path = ./clan/minimal;
        #   };
        #   flake-parts = {
        #     description = "Flake-parts";
        #     path = ./clan/flake-parts;
        #   };
        #   flake-parts-minimal = {
        #     description = "Minimal flake-parts clan template";
        #     path = ./clan/flake-parts-minimal;
        #   };
        # };
      };
    in
    rec {
      inherit (clan) clanInternals;

      clan.clanInternals.templates = templates;
      clan.templates = templates;
    };
}
