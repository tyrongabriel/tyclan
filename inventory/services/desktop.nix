_: {
  # Imports modules/nixos for custom options
  instances.desktop = {
    module.name = "@tyclan/desktop";
    module.input = "self";
    roles.gnome.tags = [ "gnome" ];
    roles.gnome.machines."yoga".settings.usesStylix = true;

    roles.cosmic.tags = [ "cosmic" ];
    roles.cosmic.machines."typc".settings.usesStylix = true;

    # Example configuration for machines with COSMIC desktop
    # roles.cosmic.machines."machine-name".settings.usesStylix = true;
  };
}
