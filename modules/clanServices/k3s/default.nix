{ ... }:
{
  _class = "clan.service";
  manifest.name = "k3s";

  roles = {
    ### HAProxy for controller load balancer ###
    controllerLoadBalancer = { };

    ### K3s controller ###
    controller = { };

    ### K3s worker ###
    worker = { };

    default = {
      perInstance =
        { instanceName, settings, ... }:
        {
          nixosModule =
            {
              config,
              pkgs,
              lib,
              ...
            }:
            let
              k3sTokenGeneratorName = "k3s-token-${instanceName}";
            in
            {
              clan.core.vars.generators."${k3sTokenGeneratorName}" = {
                share = true;
                files.token_file = { };
                runtimeInputs = [ pkgs.openssl ];

                script = ''
                  openssl rand -base64 32 | tr -d '=' | tr '+/' '-_' > "$out"/token_file
                '';
              };

            };

        };
    };
  };

}
