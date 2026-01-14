{ ... }:
{
  _class = "clan.service";
  manifest.name = "hytale-server";
  manifest.description = "Clan Service to run a hytale server";
  manifest.readme = builtins.readFile ./README.md;

  imports = [
    ./server.nix
    ./proxy.nix
  ];

  roles = {
    default = {
      description = "Default role for the hytale server";
      interface =
        { lib, ... }:
        with lib;
        {
          options = {
          };
        };
      perInstance =
        {
          instanceName,
          settings,
          roles,
          machine,
          exports,
          ...
        }:
        {
          nixosModule =
            {
              pkgs,
              ...
            }:
            {
              clan.core.vars.generators."hytale-wireguard-${instanceName}" = {
                files."privatekey" = {
                  secret = true;
                  owner = "systemd-network";
                  mode = "0400";
                };
                files."publickey" = {
                  secret = false;
                };
                files."preshared" = {
                  secret = true;
                };
                runtimeInputs = [ pkgs.wireguard-tools ];
                script = ''
                  # Generate key pair
                  wg genkey > $out/privatekey
                  wg pubkey < $out/privatekey > $out/publickey

                  # Generate pre-shared key
                  wg genpsk > $out/preshared
                '';
              };
            };
        };
    };
    server = {
      description = "Server role for the hytale server";
      interface =
        { lib, ... }:
        with lib;
        {
          options = {
            open-firewall = mkOption {
              type = types.bool;
              default = false;
              description = "Open the firewall for hytale server";
            };
            game-proxy = mkOption {
              type = types.bool;
              default = false;
              description = "Enable Proxying the game via wireguard";
            };
            game-proxy-address = mkOption {
              type = types.str;
              default = "10.0.0.1";
              description = "Address to proxy the game via wireguard";
            };
          };
        };
    };
    proxy = {
      description = "Proxy Server for hytale game";
      interface =
        { lib, ... }:
        with lib;
        {
          options = {
            open-firewall = mkOption {
              type = types.bool;
              default = true;
              description = "Open the firewall for hytale server proxy";
            };
          };
        };
    };
  };
}
