{ lib, ... }:
{
  _class = "clan.service";
  manifest.name = "netbird";
  manifest.description = "Netbird p2p vpn mesh";
  manifest.readme = builtins.readFile ./README.md;

  roles = {
    peer = {
      description = "A peer node for netbird.";
      interface =
        { lib, ... }:
        with lib;
        {
          options = {
            sshUser = mkOption {
              type = types.str;
              default = "root";
              description = "User to use for ssh";
            };
          };
        };
      perInstance =
        {
          instanceName,
          roles,
          settings,
          ...
        }:
        {
          # When adding machine: clan vars generate <machine> --regenerate --generator netbird-netbird-ip
          # To set the generated ip
          exports.networking = {
            priority = lib.mkDefault 1100;
            # TODO add user space network support to clan-cli
            peers = lib.mapAttrs (name: _machine: {
              host.var = {
                machine = name;
                generator = "netbird-${instanceName}-ip";
                file = "host";
              };
            }) roles.peer.machines;
          };
          nixosModule =
            { config, pkgs, ... }:
            {
              # Extend the existing generator with a host generator
              clan.core.vars.generators."netbird-${instanceName}-ip" = {
                files.host.secret = false;
                script = ''
                  echo "${settings.sshUser}@$(cat "$prompts/ipv4")" > "$out"/host
                '';
              };

              services.netbird = {
                enable = true;
                package = pkgs.netbird;
                # Netbird client config -> per instance
                clients.${instanceName} = {
                  name = instanceName;
                  autoStart = true;
                  openFirewall = true;
                  port = 51820;
                  #interface = 51820;
                  config = {
                    DisableAutoConnect = false;
                    WgIface = "nb-${instanceName}";
                    WgPort = 51820;
                    # Setup key is needed as value OR as env variable, so we set the NB_SETUP_KEY env var in the systemd service
                    #PreSharedKey = config.clan.core.vars.generators."netbird-${instanceName}".files.setup_key.value;
                  };

                };
              };

              systemd.services."netbird-register-${instanceName}" = {
                description = "NetBird One-Shot Registration and Login for <instanceName>";
                wantedBy = [ "multi-user.target" ];
                wants = [ "${instanceName}.service" ];
                after = [ "network-online.target" ];

                # NixOS often needs these explicitly set to '0' for oneshot services
                # to avoid the "startLimitBurst" error.
                startLimitIntervalSec = 0;
                startLimitBurst = 0;

                serviceConfig = {
                  # Use the same user/group as the primary netbird service
                  User = config.services.netbird.clients.${instanceName}.user.name; # Adjust if the user is different
                  Group = config.services.netbird.clients.${instanceName}.user.group; # Adjust if the group is different

                  # Ensure the environment file path is exactly what you specified
                  # and points to the generated file. The '-' makes it optional.
                  EnvironmentFile =
                    config.clan.core.vars.generators."netbird-${instanceName}".files.environment_file.path;

                  Type = "oneshot";
                  ExecStart = "${pkgs.netbird}/bin/netbird up"; # Use the Nix store path for netbird
                  StandardOutput = "journal";
                };
              };

              # systemd.services."${instanceName}" = {
              #   # I would expect here like execStart = 'some-nix-store-path netbird service run --setup-key-file ${config.clan.core.vars.generators."netbird-${instanceName}".files.setup_key.path}';
              #   serviceConfig = {
              #     # Implementation relies on a wrapper: https://github.com/NixOS/nixpkgs/blob/d916df777523d75f7c5acca79946652f032f633e/nixos/modules/services/networking/netbird.nix
              #     # ExecStart = lib.mkForce "${
              #     #   lib.getExe config.services.netbird.clients.${instanceName}.wrapper
              #     # } service run --setup-key-file ${
              #     #   config.clan.core.vars.generators."nectbird-${instanceName}".files.setup_key.path
              #     # }";
              #     EnvironmentFile =
              #       config.clan.core.vars.generators."netbird-${instanceName}".files.environment_file.path;
              #   };
              # };
            };
        };
    };

    controller = {
      description = "A controller node for netbird (INCOMPLETE).";

    };
  };

  # Maps over all machines and produces one result per machine, regardless of role
  perMachine =
    { instances, machine, ... }:
    {
      nixosModule =
        { config, ... }:
        {
          # Generator for ip for each instance of the machine
          clan.core.vars.generators =
            (lib.mapAttrs' (
              instanceName: _:

              # Set IPs for each instance of the host
              lib.nameValuePair "netbird-${instanceName}-ip" {
                prompts.ipv4 = {
                  description = "Netbird ip for '${instanceName}' and machine '${machine.name}'";
                  type = "line";
                  persist = true;
                };
                files.ipv4.secret = false;

                # TODO, not implemented yet
                # files.ipv6.secret = false;
              }
            ) instances)
            // lib.mapAttrs' (
              instanceName: _:

              # Set shared setup_key for netbird for each instance
              lib.nameValuePair "netbird-${instanceName}" {
                prompts.setup_key = {
                  description = "Netbird setup_key for '${instanceName}'";
                  type = "hidden";
                  persist = true; # Stored seperately aswell
                };
                share = true;
                files.environment_file = {
                  restartUnits = [
                    "${instanceName}.service"
                    "netbird-register-${instanceName}.service"
                  ];
                  secret = true;
                };

                files.setup_key = {
                  restartUnits = [
                    "${instanceName}.service"
                    "netbird-register-${instanceName}.service"
                  ];
                  secret = true;
                  mode = "0440";
                  group = config.services.netbird.clients.${instanceName}.user.group;
                };

                # Will be used as ENV file, thus we add the name and =
                script = ''
                  echo "NB_SETUP_KEY=$(cat "$prompts/setup_key")" >> "$out"/environment_file
                '';
              }
            ) instances;
        };
    };

}
