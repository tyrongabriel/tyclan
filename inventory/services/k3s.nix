_: {
  instances.k3s = {
    module.name = "@tyclan/k3s";
    module.input = "self";

    ## All k3s servers get the default config ##
    roles.default.tags."k3s" = {
    };

    ## Load Balancer ##
    roles.serverLoadBalancer.machines."ncvps01" = {
      settings = {
        tailscaleInstanceName = "tailscale-net";
        haproxyApiPort = 6443; # Clients will connect to this port
      };
    };

    ## Servers ##
    roles.server.machines = {
      "ncvps01" = {
        settings = {
          tailscaleInstanceName = "tailscale-net";
          clusterInit = true; # Is the primary server
          k3sApiPort = 6454; # Since load balancer is also here, this is the port that the load balancer will connect to
        };
      };
      "ltc01" = {
        settings = {
          tailscaleInstanceName = "tailscale-net";
          clusterInit = false; # Is the primary server
          k3sApiPort = 6443; # Since load balancer is not here
        };
      };
    };

    ## Agents ##
    roles.agent.machines = {
      "ncvps01" = {
        settings = {
          tailscaleInstanceName = "tailscale-net";
        };
      };
      "ltc01" = {
        settings = {
          tailscaleInstanceName = "tailscale-net";
        };
      };
      "hp01" = {
        settings = {
          tailscaleInstanceName = "tailscale-net";
        };
      };
    };
  };
}
