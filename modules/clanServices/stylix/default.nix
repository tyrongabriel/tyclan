{ ... }:
{
  _class = "clan.service";
  manifest.name = "Stylix";
  manifest.description = "Clan Stylix Service";
  manifest.readme = builtins.readFile ./README.md;

  imports = [ ./catppuccin.nix ];
  roles = {
    catppuccin = {
      description = "Ricing with stylix catppuccin.";
      interface =
        { lib, ... }:
        with lib;
        {
          options = {
            flavor = mkOption {
              type = types.enum [
                "mocha"
                "latte"
                "frappe"
                "macchiato"
              ];
              default = "mocha";
              description = "Stylix catppuccin flavor to use.";
            };

          };
        };

    };
  };
}
