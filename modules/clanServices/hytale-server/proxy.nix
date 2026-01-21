{ clanLib, ... }:
{
  roles.proxy.perInstance =
    {
      instanceName,
      settings,
      roles,
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

          # Open the WireGuard port and the Game port on the VPS
          networking.firewall.allowedUDPPorts = lib.mkIf settings.open-firewall (
            lib.mkForce [
              51820
              5520
            ]
          );

          networking.wireguard.enable = true;
          networking.wireguard.interfaces."wg-${lib.substring 0 12 instanceName}" = {
            ips = [ "10.200.200.1/24" ];
            listenPort = 51820;
            privateKeyFile =
              config.clan.core.vars.generators."hytale-wireguard-${instanceName}".files."privatekey".path;
            peers = lib.mapAttrsToList (name: value: {
              publicKey = clanLib.getPublicValue {
                flake = config.clan.core.settings.directory;
                machine = name;
                generator = "hytale-wireguard-${instanceName}"; # Fixed generator name to match server
                file = "publickey";
              };
              allowedIPs = [ "10.200.200.2/32" ];
            }) roles.server.machines;
          };

          # Kernel forwarding is required for NAT
          boot.kernel.sysctl."net.ipv4.ip_forward" = lib.mkForce 1;

          networking.nat = {
            enable = true;
            externalInterface = settings.external-interface; # verify with 'ip route' on your VPS
            internalInterfaces = [ "wg-${lib.substring 0 12 instanceName}" ];
            forwardPorts = [
              {
                sourcePort = 5520;
                proto = "udp";
                destination = "10.200.200.2:5520";
              }
            ];
          };

          # The magic fix: This ensures the home server sees the VPS as the sender,
          # forcing the reply back through the tunnel.
          networking.firewall.extraCommands = ''
            iptables -t nat -A POSTROUTING -d 10.200.200.2 -p udp --dport 5520 -j MASQUERADE
          '';
        };
    };
}
