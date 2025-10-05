{ ... }:
{
  _class = "clan.service";
  manifest.name = "k3s";

  roles = {
    ### HAProxy for server load balancer ###
    serverLoadBalancer = {
      interface =
        { lib, ... }:
        with lib;
        {
          options = {
            haproxyApiPort = mkOption {
              type = types.port;
              default = 6443;
              description = "The port on which the haproxy server will listen for API requests";
            };
            tailscaleInstanceName = mkOption {
              type = types.str;
              default = "tailscale-net";
              description = "The name of the tailscale instance (clan inventory) to use for this server";
            };
          };
        };
      perInstance =
        {
          instanceName,
          settings,
          roles,
          lib,
          ...
        }:

        {
          nixosModule =
            { config, ... }:
            let
              machineIpPath = (
                machineName:
                "${config.clan.core.settings.directory}/vars/per-machine/${machineName}/tailscale-${settings.tailscaleInstanceName}-ip/tailscale-ipv4/value"
              );

              # Stolen from the core zerotier module

              #uniqueStrings = list: builtins.attrNames (builtins.groupBy lib.id list);
              #serverNames = uniqueStrings (lib.attrNames roles.server.machines);
              serverMachines = lib.mapAttrsToList (name: machine: {
                name = name; # Name of the machine
                settings = machine.settings; # The k3s server interface settings of the machine
              }) roles.server.machines;
              servers = builtins.foldl' (
                ips: machine:
                if builtins.pathExists (machineIpPath machine.name) then
                  ips
                  ++ [
                    {
                      name = machine.name;
                      ip = (builtins.readFile (machineIpPath machine.name));
                      settings = machine.settings;
                    }
                  ]
                else
                  ips
              ) [ ] serverMachines;

              ## For HA PROXY ##
              generateBackendServers = map (
                server: "    server ${server.name} ${server.ip}:${toString server.settings.k3sApiPort} check"
              ) servers;

              backendServersString = lib.concatStringsSep "\n" generateBackendServers;
            in
            {
              networking.firewall.allowedTCPPorts = [
                settings.haproxyApiPort # K3s API
                8080 # Metrics
              ];
              services.haproxy = {
                enable = true;
                config = ''
                  # Global and Defaults sections remain the same...
                  global
                      log /dev/log    local0
                      #chroot /var/lib/haproxy
                      # ... (rest of global config) ...

                  defaults
                    mode tcp # Proxy TCP connections
                    timeout client 10s
                    timeout connect 5s
                    timeout server 10s
                    timeout http-request 10s

                  # 2. Key Change: Enable IPv6 in the frontend with the 'v6only' option,
                  #    and use 'bind [::]:80' to listen on all IPv6 addresses.
                  #    For dual-stack (IPv4 and IPv6), use 'bind *:80' and ensure
                  #    the kernel/OS is configured to accept both on that socket.
                  frontend web_frontend
                      # This 'bind' line enables listening on ALL IPv6 interfaces on port 80.
                      # If you want dual-stack (IPv4 & IPv6), you might use 'bind *:80'
                      # but '[::]:80' with the 'v6only' option is often safer for pure IPv6.
                      bind *:${toString settings.haproxyApiPort}
                      default_backend machine_backend

                  # Backend configuration
                  backend machine_backend
                      balance roundrobin # or leastconn
                      # Check server health every 2 seconds, with a 5-second timeout.
                      #option tcp-check
                      default-server inter 2s fall 3 rise 2 weight 1

                  ${backendServersString}

                  listen stats
                      bind *:8080
                      mode http
                      stats enable
                      stats uri /haproxy?stats
                      stats realm Haproxy\ Statistics
                      # Set a username and password for access (optional but recommended)
                      stats auth admin:securepassword
                      stats refresh 10s
                ''; # UPDATE TO USE SECRET FOR PASSWD!!
              };
            };
        };
    };

    ### K3s server ###
    server = {
      interface =
        { lib, ... }:
        with lib;
        {
          options = {
            k3sApiPort = mkOption {
              type = types.port;
              default = 6443;
              description = "The port on which the k3s server will listen for API requests";
            };
            k3sApiAddress = mkOption {
              type = types.str;
              default = "0.0.0.0"; # Default ipv4 all interfaces
              description = "The address on which the k3s server will listen for API requests";
            };
            clusterInit = mkOption {
              type = types.bool;
              default = false;
              description = "Whether or not this server initializes the cluster.";
            };
            extraFlags = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "Extra flags to pass to k3s server";
            };
            nodePortRange = mkOption {
              type = types.submodule {
                options = {
                  from = mkOption {
                    type = types.port;
                    description = "The lower bound of the port range";
                  };
                  to = mkOption {
                    type = types.port;
                    description = "The upper bound of the port range";
                  };
                };
              };
              default = {
                from = 30000;
                to = 32767;
              };
              description = "The port range to use for service node ports. Only valid when serviceCIDR is set.";
            };
            tailscaleInstanceName = mkOption {
              type = types.str;
              default = "tailscale-net";
              description = "The name of the tailscale instance (clan inventory) to use for this server";
            };
          };
        };
      perInstance =
        {
          instanceName,
          settings,
          lib,
          roles,
          machine,
          ...
        }:
        {
          nixosModule =
            { lib, config, ... }:
            let
              ipPath = (
                machineName:
                "${config.clan.core.settings.directory}/vars/per-machine/${machineName}/tailscale-${settings.tailscaleInstanceName}-ip/tailscale-ipv4/value"
              );
              getTailscaleIP = (
                machineName:
                if (builtins.pathExists (ipPath machineName)) then (builtins.readFile (ipPath machineName)) else ""
              );

              ### Fetch token ###
              generatorName = "k3s-token-${instanceName}";
              token_file =
                lib.mkDefault
                  config.clan.core.vars.generators."${generatorName}".files.token_file.path;

              ### Fetch current machine info ###
              currentMachineIp = getTailscaleIP machine.name;

              ### Fetch loadbalancer info ###
              loadBalancerName = lib.head (lib.attrNames roles.serverLoadBalancer.machines);
              loadBalancerPort = roles.serverLoadBalancer.machines."${loadBalancerName}".settings.haproxyApiPort;
              loadBalancerIp = getTailscaleIP loadBalancerName;

              ### Fetch cluster initializer ###
              # clusterInitMachineName = lib.head (
              #   lib.attrNames (
              #     lib.attrsets.filterAttrs (name: value: value.settings.clusterInit) roles.server.machines
              #   )
              #   #++ [ "ncvps01" ] # Default to ncvps01 if no other server is found (used for testing)
              # );
              #clusterInitPort = roles.server.machines."${clusterInitMachineName}".settings.k3sApiPort;
              #clusterInitIp = getTailscaleIP clusterInitMachineName;

            in
            {
              services.k3s = {
                enable = true;
                role = lib.mkForce "server"; # Set role to server, overrride if agent
                disableAgent = if lib.lists.any (role: role == "agent") machine.roles then false else true; # Disable k3s agent, if also agent then it will not be disabled
                tokenFile = token_file;
                serverAddr = lib.mkIf (!settings.clusterInit) (
                  lib.mkForce "https://${loadBalancerIp}:${toString loadBalancerPort}"
                );
                extraFlags = [
                  # Initialize a new cluster (use this only on the first server)
                  "--tls-san=${loadBalancerIp}" # Alternate certificate SAN so that the load balancer has correct cert
                  "--bind-address=${currentMachineIp}"
                  "--https-listen-port=${toString settings.k3sApiPort}"
                  "--service-node-port-range=${toString settings.nodePortRange.from}-${toString settings.nodePortRange.to}"

                  "--node-external-ip=${currentMachineIp}" # For etcd to choose correct ip?
                  "--node-ip=${currentMachineIp}" # For etcd to choose correct ip?
                  "--advertise-address=${loadBalancerIp}" # ${currentMachineIp}" # ${settings.k3sApiAddress}"
                  #"--etcd-arg=--listen-peer-urls=https://[${currentMachineIp}]:2380"
                  #"--etcd-arg=--listen-client-urls=https://[${currentMachineIp}]:2379"

                ]
                ++ settings.extraFlags
                ++ (lib.lists.optionals (settings.clusterInit) [
                  "--cluster-init"
                  # "--etcd-arg=--listen-peer-urls=https://[${currentMachineIp}]:2380"
                  # "--etcd-arg=--listen-client-urls=https://[${currentMachineIp}]:2379"
                  #"--cluster-cidr="
                  #"--service-cidr="
                ]);
              };

              networking.firewall.allowedTCPPorts = [
                settings.k3sApiPort
                2379 # etcd
                2380 # etcd peer
              ];
              networking.firewall.allowedTCPPortRanges = [ settings.nodePortRange ];
            };
        };
    };

    ### K3s agent ###
    agent = {
      interface =
        { lib, ... }:
        with lib;
        {
          options = {
            k3sApiPort = mkOption {
              type = types.port;
              default = 6443;
              description = "The port on which the k3s agent will listen for API requests";
            };
            k3sApiAddress = mkOption {
              type = types.str;
              default = "0.0.0.0"; # Default ipv4, all interfaces
              description = "The address on which the k3s agent will listen for API requests";
            };
            extraFlags = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "Extra flags to pass to k3s agent";
            };
            tailscaleInstanceName = mkOption {
              type = types.str;
              default = "tailscale-net";
              description = "The name of the tailscale instance (clan inventory) to use for this server";
            };
          };
        };
      perInstance =
        {
          instanceName,
          settings,
          roles,
          machine,
          ...
        }:
        {
          nixosModule =
            { lib, config, ... }:
            let
              ipPath = (
                machineName:
                "${config.clan.core.settings.directory}/vars/per-machine/${machineName}/tailscale-${settings.tailscaleInstanceName}-ip/tailscale-ipv4/value"
              );
              getTailscaleIP = (
                machineName:
                if (builtins.pathExists (ipPath machineName)) then (builtins.readFile (ipPath machineName)) else ""
              );
              ### Fetch token ###
              generatorName = "k3s-token-${instanceName}";
              token_file =
                lib.mkDefault
                  config.clan.core.vars.generators."${generatorName}".files.token_file.path;

              ### Fetch loadbalancer info ###
              loadBalancerName = lib.head (lib.attrNames roles.serverLoadBalancer.machines);
              loadBalancerPort = roles.serverLoadBalancer.machines."${loadBalancerName}".settings.haproxyApiPort;
              loadBalancerIp = getTailscaleIP loadBalancerName;

              ### Check whether this machine is initial server ###
              isInitialServer =
                if lib.hasAttr machine.name roles.server.machines then
                  roles.server.machines."${machine.name}".settings.clusterInit
                else
                  false;
            in
            {
              services.k3s = {
                enable = true;
                role = lib.mkDefault "agent"; # Set role to server, overrride if agent
                disableAgent = lib.mkForce false; # Disable k3s agent, if also agent then it will not be disabled
                tokenFile = token_file;
                serverAddr = lib.mkIf (!isInitialServer) "https://${loadBalancerIp}:${toString loadBalancerPort}";
                extraFlags = [
                ]
                ++ settings.extraFlags;
              };

              networking.firewall.allowedTCPPorts = [
                settings.k3sApiPort
              ];
            };
        };
    };

    ### Intended for ALL machines that have something to do with this k3s cluster ###
    default = {
      perInstance =
        { instanceName, settings, ... }:
        {
          nixosModule =
            {
              config,
              pkgs,
              lib,
              ...
            }:
            let
              k3sTokenGeneratorName = "k3s-token-${instanceName}";
            in
            {
              ### Generate a k3s token for every instance (and only for the machines in that instance) ###
              clan.core.vars.generators."${k3sTokenGeneratorName}" = {
                share = true;
                files.token_file = { };
                runtimeInputs = [ pkgs.openssl ];

                script = ''
                  openssl rand -base64 32 | tr -d '=' | tr '+/' '-_' > "$out"/token_file
                '';
              };
              boot.kernelModules = [
                "overlay"
                "br_netfilter"
              ];
              boot.kernel.sysctl = {
                "net.bridge-nf-call-iptables" = 1;
                "net.bridge-nf-call-ip6tables" = 1;
                "net.ipv4.ip_forward" = 1;
              };

              networking.firewall = {
                allowedTCPPorts = [
                  10250 # Kubelet stuff
                ];
                allowedUDPPorts = [
                  8472 # Flannel VXLAN (only if using Flannel, default in K3s)
                ];
              };

              environment.systemPackages = [ pkgs.kubernetes-helm ];
            };

        };
    };
  };

}
