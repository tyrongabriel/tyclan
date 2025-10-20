{
  inputs,
  self,
  lib,
  ...
}:
let
  # Import custom lib
  myLib = import ../lib/default.nix {
    inherit inputs;
    inherit lib;
  };

  # Import modules directly
  modules = import "${self}/modules/clanServices/default.nix" { inherit inputs; };
in
{
  clan = {
    specialArgs = {
      inherit inputs;
      inherit myLib;
    };
    inherit self;
    meta.name = "Tyclan";
    meta.description = "Tyclan Flake";
    inherit modules;
    inventory = import "${self}/inventory" {
      inherit inputs;
      inherit myLib;
    };

    # Additional NixOS configuration can be added here.
    # machines/jon/configuration.nix will be automatically imported.
    # See: https://docs.clan.lol/guides/more-machines/#automatic-registration
    machines = {
      # jon = { config, ... }: {
      #   environment.systemPackages = [ pkgs.asciinema ];
      # };
    };
  };
  # flake =
  #   let
  #     # Import modules directly
  #     modules = import "${self}/modules/clanServices/default.nix" { inherit inputs; };

  #     # Build clan using new API
  #     clanModule = inputs.clan-core.lib.clan {
  #       specialArgs = { inherit inputs; };
  #       inherit self;
  #       meta.name = "Tyclan";
  #       inherit modules;
  #       inventory = import "${self}/inventory" { inherit inputs; };
  #     };
  #   in
  #   {
  #     # Expose clan outputs using new API structure
  #     #inherit (clanModule.config) nixosConfigurations clanInternals;
  #     #clan = clanModule.config;
  #   };
}
