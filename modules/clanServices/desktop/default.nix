{ ... }:
{
  _class = "clan.service";
  manifest.name = "desktop";
  manifest.description = "Clan Desktop Service to set desktop environment";
  manifest.readme = builtins.readFile ./README.md;

  imports = [ ./gnome.nix ];

  roles = {
    gnome = {
      description = "Gnome (Wayland) Desktop environment.";
      interface =
        { lib, ... }:
        with lib;
        {
          options = {

          };
        };
    };
  };
}
