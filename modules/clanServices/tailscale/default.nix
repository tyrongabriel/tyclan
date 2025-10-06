_: {
  _class = "clan.service";

  manifest = {
    name = "tailscale";
    description = "Tailscale VPN - Zero-config mesh networking";
    categories = [
      "Networking"
      "VPN"
    ];
  };

  roles.peer = {
    interface =
      { lib, ... }:
      {
        freeformType = lib.types.attrsOf lib.types.anything;

        options = {
          sshUser = lib.mkOption {
            type = lib.types.str;
            default = "root";
            description = "User to use for ssh";
          };
          exitNode = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable exit node";
          };
          enableHostAliases = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Automatically sync Tailscale device names to /etc/hosts";
          };
        };
      };

    perInstance =
      {
        instanceName,
        settings,
        roles,
        lib,
        machine,
        ...
      }:
      let
        generatorName = "tailscale-${instanceName}";
      in
      {
        exports.networking = {
          priority = lib.mkDefault 1050;
          # TODO add user space network support to clan-cli
          peers = lib.mapAttrs (name: _machine: {
            host.var = {
              machine = name;
              generator = "${generatorName}-ip";
              file = "tailscale-host";
            };
          }) roles.peer.machines;
        };
        nixosModule =
          {
            config,
            pkgs,
            lib,
            ...
          }:
          let
            enableHostAliases = settings.enableHostAliases or true;
            enableSSH = settings.enableSSH or false;
            exitNode = settings.exitNode or false;

            tailscaleSettings = builtins.removeAttrs settings [
              "enableHostAliases"
              "enableSSH"
              "exitNode"
              "sshUser"
            ];

            extraUpFlags =
              (lib.optional enableSSH "--ssh")
              ++ (lib.optional exitNode "--advertise-exit-node")
              ++ (settings.extraUpFlags or [ ]);

            finalSettings = tailscaleSettings // {
              authKeyFile = lib.mkDefault config.clan.core.vars.generators."${generatorName}".files.auth_key.path;
              inherit extraUpFlags;
            };
          in
          {
            imports = [ ./host-sync.nix ];
            warnings = lib.lists.optional settings.enableSSH "Tailscale ssh enabled for ${machine.name}, allows root login!";

            clan.core.vars.generators."${generatorName}" = {
              share = true;
              files.auth_key = { };
              runtimeInputs = [ pkgs.coreutils ];

              prompts.auth_key = {
                description = "Tailscale auth key for instance '${instanceName}'";
                type = "hidden";
                persist = true;
              };

              script = ''
                cat "$prompts"/auth_key > "$out"/auth_key
              '';
            };

            clan.core.vars.generators."${generatorName}-ip" = {
              share = false; # At the very least does not work with clan networking! as each network has one generator, but share would need one per machine.
              files.tailscale-ipv4 = {
                secret = false;
              };
              files.tailscale-ipv6 = {
                secret = false;
              };
              files.tailscale-host = {
                secret = false;
              };
              runtimeInputs = [ pkgs.coreutils ];

              prompts.tailscale-ipv4 = {
                description = "Tailscale ipv4 address for instance '${instanceName}' and machine '${machine.name}'";
                type = "line";
                persist = false;
              };

              prompts.tailscale-ipv6 = {
                description = "Tailscale ipv6 address for instance '${instanceName}' and machine '${machine.name}'";
                type = "line";
                persist = false;
              };

              ## Not needed with persist
              script = ''
                cat $prompts/tailscale-ipv4 > "$out"/tailscale-ipv4 &&
                cat $prompts/tailscale-ipv6 > "$out"/tailscale-ipv6 &&
                echo "${settings.sshUser}@$(cat "$prompts/tailscale-ipv4")" > "$out"/tailscale-host
              '';

              #runtimeInputs = [ pkgs.tailscale ];

              # script = ''
              #   tailscale ip -4 | head -n1 > "$out"/tailscale-ipv4 &&
              #   tailscale ip -6 | head -n1 > "$out"/tailscale-ipv6
              # '';
            };

            services.tailscale = finalSettings // {
              enable = true;
              useRoutingFeatures = lib.mkDefault "both";
            };

            services.tailscale-host-sync.enable = enableHostAliases;

            # Don't block boot
            systemd.services.tailscaled-autoconnect = lib.mkIf (finalSettings.autoconnect or false) {
              wantedBy = lib.mkForce [ ];
            };

            networking.firewall = {
              checkReversePath = "loose";
              trustedInterfaces = [ "tailscale0" ];
              allowedUDPPorts = [ 41641 ];
            };

            # NAT for exit nodes
            networking.nat = lib.mkIf exitNode {
              enable = true;
              externalInterface = lib.mkDefault (if config.networking.interfaces ? "eth0" then "eth0" else "");
              internalInterfaces = [ "tailscale0" ];
            };

            # Install tailscale CLI
            environment.systemPackages = [ pkgs.tailscale ];
          };
      };
  };
}
