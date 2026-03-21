{
  lib,
  config,
  pkgs,
  machine,
  roles,
  settings,
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
    serverAddr = lib.mkIf (!isInitialServer) "https://[${lbIp}]:${toString lbPort}";
    extraFlags = settings.extraFlags;
  };

  # For Longhorn to work!
  environment.systemPackages = with pkgs; [
    # Other packages...
    openiscsi
    util-linux # For longhorn to get fstrim
  ];
  # Terrible fucking hack to get longhorn working with fstrim
  system.activationScripts.longhorn-fstrim = {
    text = ''
      mkdir -p /usr/bin
      ln -sfn /run/current-system/sw/bin/fstrim /usr/bin/fstrim
    '';
  };
  #services.envfs.enable = true; # Links things (like fstrim) to /usr/bin
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
}
