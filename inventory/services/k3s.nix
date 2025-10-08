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
    roles.serverLoadBalancer = {
      settings = {
        haproxyApiPort = 6443; # Clients will connect to this port
      };
      tags."k3s-proxy" = { };
    };

    ## Servers ##
    roles.server = {
      tags."k3s-server" = { };
      machines = {
        "ncvps01".settings = {
          k3sApiPort = 6454; # Since load balancer is also here, this is the port that the load balancer will connect to
          clusterInit = true;
        };
      };
    };

    ## Agents ##
    roles.agent.tags."k3s-agent" = { };
  };
}
