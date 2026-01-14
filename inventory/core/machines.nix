_: {
  machines = {
    yoga = {
      tags = [
        #"passwordless-sudo"
        "auto-gc"
        "laptop"
        "gnome"
        "catppuccin-mocha"
        "explicit-update"
        "netbird"
      ];
      #deploy.targetHost = "tyron@152.53.149.109";
    };
    typc = {
      tags = [
        "auto-gc"
        "laptop"
        #"gnome"
        "cosmic"
        "catppuccin-mocha"
        "explicit-update"
        "netbird"
      ];
    };
    ncvps01 = {
      tags = [
        "passwordless-sudo"
        "auto-gc"
        "k3s"
        "k3s-server"
        "k3s-agent"
        "vps"
        #"netbird"
      ];
      #deploy.targetHost = "tyron@152.53.149.109";
    };
    ncvps02 = {
      tags = [
        "k3s"
        "passwordless-sudo"
        "auto-gc"
        "k3s-proxy"
        "vps"
      ];
      #deploy.targetHost = "tyron@152.53.149.109";
    };
    ltc01 = {
      tags = [
        "passwordless-sudo"
        "auto-gc"
        "k3s"
        "k3s-server"
        "k3s-agent"
        "pc"
      ];
    };
    hp01 = {
      tags = [
        "passwordless-sudo"
        "auto-gc"
        "k3s"
        "k3s-server"
        "k3s-agent"
        "pc"
      ];
    };
  };
}
