{
  config,
  pkgs,
  lib,
  instanceName,
  settings,
  machine,
  roles,
  clanLib,
  directory,
  ...
}:
let
  k3sTokenGeneratorName = "k3s-token-${instanceName}";
  ### Fetch token ###
  generatorName = "k3s-token-${instanceName}";
  token_file =
    lib.mkDefault
      config.clan.core.vars.generators."${generatorName}".files.token_file.path;

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

  ### Check whether this machine is initial server ###
  isInitialServer =
    if lib.hasAttr machine.name roles.server.machines then
      roles.server.machines."${machine.name}".settings.clusterInit
    else
      false;
in
with lib;
{
  swapDevices = lib.mkForce [ ]; # NEeded for k3s since it does not want any swap
  services.k3s = {
    enable = true;
    tokenFile = token_file;
    serverAddr = lib.mkIf (!isInitialServer) "https://[${lbIp}]:${toString lbPort}";
    nodeIP = currentMachineIp;
    nodeName = machine.name;
    extraFlags = [
      #"--flannel-iface z"
      "--flannel-ipv6-masq"
      "--bind-address=${currentMachineIp}"
      "--node-external-ip=${currentMachineIp}" # For etcd to choose correct ip?
      #"--node-ip=${currentMachineIp}" # For etcd to choose correct ip?
      # For kube-prometheus: https://fabianlee.org/2022/07/02/prometheus-installing-kube-prometheus-stack-on-k3s-cluster/
      "--kube-proxy-arg=metrics-bind-address=::"
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
    "net.bridge-nf-call-iptables" = mkDefault 1;
    "net.bridge-nf-call-ip6tables" = mkDefault 1;
    "net.ipv4.ip_forward" = 1;
    # For cloudflare tunnel instance!
    "net.core.rmem_max" = 10000000;
    "net.core.wmem_max" = 10000000;
  };
  # boot.extraModprobeConfig = ''
  #   install nft-expr-counter /bin/true
  #   install nft-expr-immediate /bin/true
  #   install nft-expr-meta /bin/true
  #   install nft-expr-nat /bin/true
  #   install nft-expr_lookup /bin/true
  # '';

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
}
