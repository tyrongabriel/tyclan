{
  lib,
  config,
  settings,
  machine,
  roles,
  clanLib,
  directory,
  ...
}:
let
  getMachineIp =
    name:
    clanLib.getPublicValue {
      flake = directory;
      machine = name;
      generator = "tailscale-tailscale-net-ip";
      file = "tailscale-ipv6";
      default = null;
    };

  ### Fetch loadbalancer info ###
  lbName = lib.head (lib.attrNames roles.loadBalancer.machines);
  lbPort = roles.loadBalancer.machines."${lbName}".settings.k3sApiPort;
  lbIp = getMachineIp lbName;

  ### Fetch current machine info ###
  currentMachineIp = getMachineIp machine.name;

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
    clusterInit = settings.clusterInit;
    disableAgent = if lib.lists.any (role: role == "agent") machine.roles then false else true; # Disable k3s agent, if also agent then it will not be disabled
    serverAddr =
      if (!settings.clusterInit) then (lib.mkForce "https://[${lbIp}]:${toString lbPort}") else "";
    extraFlags = [
      "--advertise-port=${toString settings.k3sAdvertisedApiPort}" # Needs to only be defined in server, but in my service its defined in node!
      "--https-listen-port=${toString settings.k3sApiPort}"
      "--tls-san=${lbIp}" # Alternate certificate SAN so that the load balancer has correct cert
      "--service-node-port-range=${toString settings.nodePortRange.from}-${toString settings.nodePortRange.to}"
      "--advertise-address=${currentMachineIp}" # ${currentMachineIp}" # ${settings.k3sApiAddress}"
      "--cluster-cidr=fdba:bb29:4301::/56" # 10.42.0.0/16,
      "--service-cidr=fdba:bb29:4302::/112" # 10.43.0.0/16,
      "--flannel-backend=wireguard-native"

      # For kube-prometheus: https://fabianlee.org/2022/07/02/prometheus-installing-kube-prometheus-stack-on-k3s-cluster/
      ## Kube-Scheduler
      "--kube-scheduler-arg=bind-address=::"
      ## Etcd
      "--etcd-expose-metrics" # Server only
      ## Kube Controller manager
      "--kube-controller-manager-arg=bind-address=::" # Server only
      "--kube-apiserver-arg=bind-address=::"
    ]
    ++ settings.extraFlags;
  };

  networking.firewall.allowedTCPPorts = [
    settings.k3sApiPort # k3s api
    2379 # etcd
    2380 # etcd peer
  ];
  networking.firewall.allowedTCPPortRanges = [ settings.nodePortRange ];

}
