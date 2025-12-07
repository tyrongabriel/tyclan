_: {
  # Imports modules/nixos for custom options
  instances.desktop = {
    module.name = "@tyclan/desktop";
    module.input = "self";
    roles.gnome.tags.gnome = { };
  };
}
