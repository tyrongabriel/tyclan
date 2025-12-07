_: {
  # Imports modules/nixos for custom options
  instances.stylix = {
    module.name = "@tyclan/stylix";
    module.input = "self";
    roles.catppuccin.tags.catppuccin-mocha = { };
  };
}
