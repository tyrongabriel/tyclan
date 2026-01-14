{ clanLib, ... }:
{
  roles.server.perInstance =
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
          lib,
          config,
          ...
        }:
        {
          virtualisation.docker.enable = true;
          networking.firewall.allowedUDPPorts = lib.mkIf settings.open-firewall (lib.mkForce [ 5520 ]);

          # Autostart the docker https://github.com/indifferentbroccoli/hytale-server-docker
          # (For now manual!!)

          networking.wireguard.enable = true;
          networking.wireguard.interfaces = {
            "wg-${lib.substring 0 12 instanceName}" = {
              ips = [ "10.200.200.2/24" ];
              privateKeyFile =
                config.clan.core.vars.generators."hytale-wireguard-${instanceName}".files."privatekey".path;
              peers = lib.mapAttrsToList (name: value: {
                publicKey = clanLib.getPublicValue {
                  flake = config.clan.core.settings.directory;
                  machine = name;
                  generator = "hytale-wireguard-${instanceName}";
                  file = "publickey";
                };
                allowedIPs = [ "10.200.200.1/32" ];
                endpoint = "${settings.game-proxy-address}:51820"; # Replace with your VPS IP
                persistentKeepalive = 25; # Keep connection alive from behind NAT
              }) roles.proxy.machines;

            };
          };

          # Enable the game server (assuming it runs on port 5520/udp)
          # systemd.services.game-server = {
          #   description = "Game Server";
          #   after = [ "network.target" ];
          #   wantedBy = [ "multi-user.target" ];
          #   serviceConfig = {
          #     ExecStart = "${pkgs.your-game-package}/bin/game-server"; # Replace with actual game server executable
          #     WorkingDirectory = "/var/lib/game-server";
          #     Restart = "always";
          #   };
          # };

        };
    };
}
