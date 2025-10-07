_: {
  instances.k3s = {
    module.name = "@tyclan/k3s";
    module.input = "self";

    ## All k3s servers get the default config ##
    roles.default = {
      settings = {
        tailscaleInstanceName = "tailscale-net";
      };

      machines = {
        ncvps01.settings = {
          k3sApiPort = 6454; # Since load balancer is also here, this is the port that the load balancer will connect to
        };
      };
      tags."k3s" = { };
    };

    ## Load Balancer ##
    roles.serverLoadBalancer.machines."ncvps01" = {
      settings = {
        haproxyApiPort = 6443; # Clients will connect to this port
      };
    };

    ## Servers ##
    roles.server.machines = {
      "ncvps01".settings = {
        k3sApiPort = 6454; # Since load balancer is also here, this is the port that the load balancer will connect to
        clusterInit = true;
      };
      "ltc01" = { };
      "hp01" = { };
    };

    ## Agents ##
    roles.agent.machines = {
      "ncvps01" = { };
      "ltc01" = { };
      "hp01" = { };
    };
  };
}
