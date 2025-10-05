_: {
  instances.k3s = {
    module.name = "@tyclan/k3s";
    module.input = "self";
    roles.default.tags."k3s" = { };

    ## Load Balancer ##
    roles.serverLoadBalancer.machines."ncvps01" = {
      settings = {
        haproxyApiPort = 6443; # Clients will connect to this port
      };
    };

    ## Servers ##
    roles.server.machines = {
      "ncvps01" = {
        settings = {
          clusterInit = true; # Is the primary server
          k3sApiPort = 6444; # Since load balancer is also here, this is the port that the load balancer will connect to
        };
      };
    };

    ## Agents ##
    roles.agent.machines = {
      "ncvps01" = { };
    };
  };
}
