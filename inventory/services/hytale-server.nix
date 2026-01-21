_: {
  # Imports modules/nixos for custom options
  # instances.hytale-server = {
  #   module.name = "@tyclan/hytale-server";
  #   module.input = "self";
  #   roles.default.machines = {
  #     "ltc01" = { };
  #     "ncvps01" = { };
  #   };
  #   roles.proxy.machines."ncvps01".settings = {
  #     open-firewall = true;
  #     external-interface = "ens3";
  #   };

  #   roles.server.machines."ltc01".settings = {
  #     open-firewall = true;
  #     game-proxy = true;
  #     game-proxy-address = "152.53.149.109";
  #   };

  #   # Example configuration for machines with COSMIC desktop
  #   # roles.cosmic.machines."machine-name".settings.usesStylix = true;
  # };
}
