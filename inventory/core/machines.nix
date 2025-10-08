_: {
  machines = {
    ncvps01 = {
      tags = [
        "k3s"
        "k3s-proxy"
        "k3s-server"
        "k3s-agent"
        "vps"
      ];
      #deploy.targetHost = "tyron@152.53.149.109";
    };
    ncvps02 = {
      tags = [
        #"k3s-proxy"
        "vps"
      ];
      #deploy.targetHost = "tyron@152.53.149.109";
    };
    ltc01 = {
      tags = [
        "k3s"
        "k3s-server"
        "k3s-agent"
        "pc"
      ];
    };
    hp01 = {
      tags = [
        "k3s"
        "k3s-server"
        "k3s-agent"
        "pc"
      ];
    };
  };
}
