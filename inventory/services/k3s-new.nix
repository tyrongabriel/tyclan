_: {
  instances.k3s = {
    module.name = "@tyclan/k3s-new";
    module.input = "self";
    roles.loadBalancer = {
      # settings = {
      #   haproxyApiPort = 6443; # Clients will connect to this port
      # };
      tags."k3s-proxy" = { };
    };

    ## Servers ##
    roles.server = {
      tags."k3s-server" = { };
      machines = {
        "ncvps01".settings = {
          clusterInit = true;
        };
      };
    };

    ## Agents ##
    roles.agent.tags."k3s-agent" = { };
  };
}
