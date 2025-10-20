{ ... }:
{
  _class = "clan.service";
  manifest.name = "k3s";
  manifest.description = "K3s cluster management";
  manifest.readme = builtins.readFile ./README.md;

  roles = {
    ### HAProxy for server load balancer ###
    serverLoadBalancer = {
      description = "The load balancer to which the other nodes will point to to access the control plane.";
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
          };
        };
      perInstance =
        {
          instanceName,
          settings,
          roles,
          lib,
          exports,
          machine,
          ...
        }:
        {
          nixosModule =
            { config, ... }:
            let
              machineIpPath = (
                machineName:
                "${config.clan.core.settings.directory}/vars/per-machine/${machineName}/tailscale-${
                  roles.default.machines."${machine.name}".settings.tailscaleInstanceName

                }-ip/tailscale-ipv4/value"
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

              ## For Internal K3s load balancing ##

              generateBackendServers = lib.strings.concatStringsSep "\n    " (
                map (
                  server:
                  "server ${server.name} ${server.ip}:${
                    toString roles.node.machines."${server.name}".settings.k3sApiPort
                  } check"
                ) servers
              );
              ## For ingress load balancing ##
              generateBackendServersWithPort = (
                port:
                lib.strings.concatStringsSep "\n    " (
                  map (server: "server ${server.name} ${server.ip}:${toString port} check") servers
                )
              );

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

                  #---------------------------------------------------------------------
                  # Frontend for K3s internal load balancing (Port 6443)
                  # This is used for agents/servers to talk to each other
                  #---------------------------------------------------------------------
                  frontend k3s-internal-frontend
                      bind *:${toString settings.haproxyApiPort}
                      default_backend k3s-internal-backend

                  #---------------------------------------------------------------------
                  # Backend for K3s internal load balancing (Port 6443)
                  # These are all the servers in the cluster that are running K3s.
                  #---------------------------------------------------------------------
                  backend k3s-internal-backend
                      balance roundrobin # or leastconn
                      # Check server health every 2 seconds, with a 5-second timeout.
                      #option tcp-check
                      default-server inter 2s fall 3 rise 2 weight 1
                      ${toString generateBackendServers}


                  #---------------------------------------------------------------------
                  # Frontend for HTTP Ingress (Port 80)
                  # This handles all non-secure web traffic.
                  #---------------------------------------------------------------------
                  frontend k3s_ingress_http
                      bind *:80
                      mode http
                      default_backend k3s_traefik_http

                  #---------------------------------------------------------------------
                  # Frontend for HTTPS Ingress (Port 443)
                  # This is crucial if you'll use TLS/Cert-Manager with Traefik later.
                  # We use 'tcp' mode for SSL passthrough (recommended).
                  #---------------------------------------------------------------------
                  frontend k3s_ingress_https
                      bind *:443
                      mode tcp
                      default_backend k3s_traefik_https

                  #---------------------------------------------------------------------
                  # Backend for HTTP Traffic (Port 80)
                  # Routes HTTP traffic evenly to all K3s servers running Traefik.
                  #---------------------------------------------------------------------
                  backend k3s_traefik_http
                      mode http
                      balance roundrobin
                      ${toString (generateBackendServersWithPort 80)}

                  #---------------------------------------------------------------------
                  # Backend for HTTPS Traffic (Port 443)
                  # Routes HTTPS traffic evenly to all K3s servers running Traefik.
                  #---------------------------------------------------------------------
                  backend k3s_traefik_https
                      mode tcp
                      balance roundrobin
                      ${toString (generateBackendServersWithPort 443)}

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
                # Use the following command to get formatted config:
                # clan select nixosConfigurations.<name>.config.services.haproxy.config | sed 's/\\n/\n/g'
              };
            };
        };
    };

    ### K3s server ###
    server = {
      description = "A k3s control plane server node.";
      interface =
        { lib, ... }:
        with lib;
        {
          options = {
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
          };
        };
      perInstance =
        {
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
                "${config.clan.core.settings.directory}/vars/per-machine/${machineName}/tailscale-${
                  roles.default.machines."${machine.name}".settings.tailscaleInstanceName
                }-ip/tailscale-ipv4/value"
              );
              getTailscaleIP = (
                machineName:
                if (builtins.pathExists (ipPath machineName)) then (builtins.readFile (ipPath machineName)) else ""
              );

              ### Fetch loadbalancer info ###
              loadBalancerName = lib.head (lib.attrNames roles.serverLoadBalancer.machines);
              loadBalancerPort = roles.serverLoadBalancer.machines."${loadBalancerName}".settings.haproxyApiPort;
              loadBalancerIp = getTailscaleIP loadBalancerName;

              ### Fetch current machine info ###
              currentMachineIp = getTailscaleIP machine.name;

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
                serverAddr =
                  if (!settings.clusterInit) then
                    (lib.mkForce "https://${loadBalancerIp}:${toString loadBalancerPort}")
                  else
                    "";
                extraFlags = [
                  "--advertise-port=${toString roles.node.machines."${machine.name}".settings.k3sAdvertisedApiPort}" # Needs to only be defined in server, but in my service its defined in node!
                  "--https-listen-port=${toString roles.node.machines."${machine.name}".settings.k3sApiPort}"
                  "--tls-san=${loadBalancerIp}" # Alternate certificate SAN so that the load balancer has correct cert
                  "--service-node-port-range=${toString settings.nodePortRange.from}-${toString settings.nodePortRange.to}"
                  "--advertise-address=${currentMachineIp}" # ${currentMachineIp}" # ${settings.k3sApiAddress}"
                  "--cluster-cidr=10.42.0.0/16"
                  "--service-cidr=10.43.0.0/16"

                  # For kube-prometheus: https://fabianlee.org/2022/07/02/prometheus-installing-kube-prometheus-stack-on-k3s-cluster/
                  ## Kube-Scheduler
                  "--kube-scheduler-arg=bind-address=0.0.0.0"
                  ## Etcd
                  "--etcd-expose-metrics" # Server only
                  ## Kube Controller manager
                  "--kube-controller-manager-arg=bind-address=0.0.0.0" # Server only
                ]
                ++ settings.extraFlags
                ++ (lib.lists.optionals (settings.clusterInit) [
                  "--cluster-init"
                ]);
              };

              networking.firewall.allowedTCPPorts = [
                2379 # etcd
                2380 # etcd peer
              ];
              networking.firewall.allowedTCPPortRanges = [ settings.nodePortRange ];
            };
        };
    };

    ### K3s agent ###
    agent = {
      description = "A regular k3s agent node.";
      interface =
        { lib, ... }:
        with lib;
        {
          options = {
            extraFlags = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "Extra flags to pass to k3s agent";
            };
          };
        };
      perInstance =
        {
          settings,
          roles,
          machine,
          ...
        }:
        {
          nixosModule =
            {
              lib,
              config,
              pkgs,
              ...
            }:
            let
              ipPath = (
                machineName:
                "${config.clan.core.settings.directory}/vars/per-machine/${machineName}/tailscale-${
                  roles.default.machines."${machine.name}".settings.tailscaleInstanceName
                }-ip/tailscale-ipv4/value"
              );
              getTailscaleIP = (
                machineName:
                if (builtins.pathExists (ipPath machineName)) then (builtins.readFile (ipPath machineName)) else ""
              );

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
                serverAddr = lib.mkIf (!isInitialServer) "https://${loadBalancerIp}:${toString loadBalancerPort}";
                extraFlags = settings.extraFlags;
              };

              # For Longhorn to work!
              environment.systemPackages = with pkgs; [
                # Other packages...
                openiscsi
              ];
              # Fix for longhorn https://github.com/longhorn/longhorn/issues/2166#issuecomment-2994323945
              services.openiscsi = {
                enable = true;
                name = "${config.networking.hostName}-initiatorhost";
              };
              systemd.services.iscsid.serviceConfig = {
                PrivateMounts = "yes";
                BindPaths = "/run/current-system/sw/bin:/bin";
              };

              # Enable the iSCSI daemon
              #services.openiscsi.enable = lib.mkForce true;
            };
        };
    };

    ### Intended for ALL machines that will run k3s in this cluster ###
    node = {
      description = "A node (Either server, agent or both) that will have basic node config.";
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
            k3sAdvertisedApiPort = mkOption {
              type = types.port;
              default = 6443;
              description = "The port on which the k3s agent will advertise for API requests";
            };
            extraFlags = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "Extra flags to pass to k3s agent";
            };
          };
        };
      perInstance =
        {
          instanceName,
          settings,
          machine,
          roles,
          ...
        }:
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
              ### Fetch token ###
              generatorName = "k3s-token-${instanceName}";
              token_file =
                lib.mkDefault
                  config.clan.core.vars.generators."${generatorName}".files.token_file.path;

              ipPath = (
                machineName:
                "${config.clan.core.settings.directory}/vars/per-machine/${machineName}/tailscale-${
                  roles.default.machines."${machine.name}".settings.tailscaleInstanceName
                }-ip/tailscale-ipv4/value"
              );
              getTailscaleIP = (
                machineName:
                if (builtins.pathExists (ipPath machineName)) then (builtins.readFile (ipPath machineName)) else ""
              );

              ### Fetch current machine info ###
              currentMachineIp = getTailscaleIP machine.name;

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
              swapDevices = lib.mkForce [ ]; # NEeded for k3s since it does not want any swap
              services.k3s = {
                enable = true;
                tokenFile = token_file;
                serverAddr = lib.mkIf (!isInitialServer) "https://${loadBalancerIp}:${toString loadBalancerPort}";

                extraFlags = [
                  "--flannel-iface tailscale0"
                  "--bind-address=${currentMachineIp}"
                  "--node-external-ip=${currentMachineIp}" # For etcd to choose correct ip?
                  "--node-ip=${currentMachineIp}" # For etcd to choose correct ip?
                  # For kube-prometheus: https://fabianlee.org/2022/07/02/prometheus-installing-kube-prometheus-stack-on-k3s-cluster/
                  "--kube-proxy-arg=metrics-bind-address=0.0.0.0"
                ]
                ++ settings.extraFlags;
              };

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
                "nft_counter"
                "nf_conntrack"
                "nft-expr-counter"
              ];
              boot.kernel.sysctl = {
                "net.bridge-nf-call-iptables" = 1;
                "net.bridge-nf-call-ip6tables" = 1;
                "net.ipv4.ip_forward" = 1;
                # For cloudflare tunnel instance!
                "net.core.rmem_max" = 10000000;
                "net.core.wmem_max" = 10000000;
              };
              boot.extraModprobeConfig = ''
                install nft-expr-counter /bin/true
                install nft-expr-immediate /bin/true
                install nft-expr-meta /bin/true
                install nft-expr-nat /bin/true
                install nft-expr_lookup /bin/true
              '';

              systemd.services = {
                nftables = {
                  enable = true;
                  after = [ "network.target" ];
                  serviceConfig = {
                    Environment = "IPTABLES_BACKEND=nft";
                  };
                };
              };

              networking.firewall = {
                allowedTCPPorts = [
                  settings.k3sApiPort # K3s API
                  10250 # Kubelet stuff
                  7844 # Cloudflare quic

                ];
                allowedUDPPorts = [
                  8472 # Flannel VXLAN (only if using Flannel, default in K3s)
                  10250 # Kubelet stuff
                  7844 # Cloudflare quic
                  #443 # Cloudflare
                  #80 # Cloudflare
                ];
              };

              # Deduplicate settings
              environment.systemPackages = [ pkgs.kubernetes-helm ];

              # For performance
              services.thermald.enable = lib.mkDefault true; # Manages the CPU temperature
              powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
            };
        };
    };
    ### Intended for ALL machines that have something to do with this k3s cluster ###
    default = {
      description = "Default k3s machine config.";
      interface =
        { lib, ... }:
        with lib;
        {
          options = {
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
          machine,
          roles,
          ...
        }:
        {
          nixosModule =
            {
              config,
              pkgs,
              lib,
              ...
            }:
            {

            };
        };
    };
  };
}
