{
  config,
  pkgs,
  lib,
  roles,
  directory,
  clanLib,
  settings,
  ...
}:
with lib;
let
  serverMachines = lib.mapAttrsToList (name: machine: {
    name = name; # Name of the machine
    settings = machine.settings; # The k3s server interface settings of the machine
  }) roles.server.machines;

  servers = map (serverMachine: rec {
    name = serverMachine.name;
    ip = clanLib.getPublicValue {
      machine = serverMachine.name;
      generator = "tailscale-tailscale-net-ip";
      file = "tailscale-ipv6";
      flake = directory;
    };
    # Required for HAProxy when combining an IPv6 address with a port
    mappedIp = "[${ip}]";
    settings = serverMachine.settings;
  }) serverMachines;

  # Format the upstream servers for HAProxy
  haproxyBackendServers = lib.concatMapStringsSep "\n      " (
    server: "server ${server.name} ${server.mappedIp}:${toString settings.k3sApiPort} check"
  ) servers;

in
{
  # Enable HAProxy for Layer 4 (TCP) load balancing
  services.haproxy = {
    enable = true;
    config = ''
      global
        log /dev/log local0
        maxconn 4096

      defaults
        log global
        mode tcp
        option tcplog
        timeout connect 5s
        timeout client 50s
        timeout server 50s

      frontend k3s_frontend
        bind *:${toString settings.k3sApiPort}
        bind [::]:${toString settings.k3sApiPort}
        default_backend k3s_backend

      backend k3s_backend
        balance roundrobin
        ${haproxyBackendServers}
    '';
  };

  # Firewall configuration to allow traffic on these ports
  networking.firewall = {
    allowedTCPPorts = [
      6443
    ];
  };
}
