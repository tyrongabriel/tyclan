{ ... }:
{
  _class = "clan.service";
  manifest.name = "k3s";

  roles = {
    ### HAProxy for controller load balancer ###
    controllerLoadBalancer = { };

    ### K3s controller ###
    controller = {
      perInstance =
        { instanceName, settings, ... }:
        {
          nixosModule =
            { lib, config, ... }:
            let
              generatorName = "k3s-token-${instanceName}";
              token_file =
                lib.mkDefault
                  config.clan.core.vars.generators."${generatorName}".files.token_file.path;
            in
            { };
        };
    };

    ### K3s worker ###
    worker = {
      perInstance =
        { instanceName, settings, ... }:
        {
          nixosModule =
            { lib, config, ... }:
            let
              generatorName = "k3s-token-${instanceName}";
              token_file =
                lib.mkDefault
                  config.clan.core.vars.generators."${generatorName}".files.token_file.path;
            in
            { };
        };
    };

    ### Intended for ALL machines that have something to do with this k3s cluster ###
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
              ### Generate a k3s token for every instance (and only for the machines in that instance) ###
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
