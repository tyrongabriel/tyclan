_: {
  # Imports modules/nixos for custom options
  instances.nixos-modules = {
    module.name = "importer";
    roles.default.tags.all = { };
    roles.default.extraModules = [ ../../modules/nixos/default.nix ];
  };
}
