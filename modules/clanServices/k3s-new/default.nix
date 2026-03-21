{
  clanLib,
  config,
  lib,
  directory,
  ...
}:
{
  _class = "clan.service";
  manifest.name = "k3s";
  manifest.description = "K3s Cluster setup";
  manifest.categories = [ "Cloud" ];
  manifest.readme = builtins.readFile ./README.md;
  # manifest.exports.out = [
  #   "networking"
  #   "peer"
  # ];
  #

  roles.loadBalancer = {
    description = "Load Balancer for K3s Cluster";
    interface =
      { lib, ... }:
      {
        options.k3sApiPort = lib.mkOption {
          type = lib.types.port;
          description = ''
            port to load balance the k3s api
          '';
          example = 6443;
          default = 6443;
        };

      };
    perInstance =
      {
        instanceName,
        roles,
        mkExports,
        machine,
        settings,
        ...
      }:
      {
        nixosModule =
          {
            config,
            lib,
            pkgs,
            ...
          }:
          {
            imports = [
              (import ./load-balancer.nix {
                inherit
                  clanLib
                  instanceName
                  roles
                  config
                  lib
                  pkgs
                  mkExports
                  machine
                  settings
                  directory
                  ;
              })
            ];

            config = {
              # config
            };
          };

      };
  };

  roles.server = {
    description = "K3s Server";
    interface =
      { lib, ... }:
      with lib;
      {
        options = {
          clusterInit = mkOption {
            type = types.bool;
            default = false;
            description = "Whether or not this server initializes the cluster.";
          };
          extraFlags = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Extra flags to pass to k3s server";
          };
          k3sApiPort = mkOption {
            type = types.port;
            default = 6443;
            description = "The port on which the k3s server will listen for API requests";
          };
          k3sAdvertisedApiPort = mkOption {
            type = types.port;
            default = 6443;
            description = "The port on which the k3s server will advertise for API requests";
          };
          nodePortRange = mkOption {
            type = types.submodule {
              options = {
                from = mkOption {
                  type = types.port;
                  description = "The lower bound of the port range";
                };
                to = mkOption {
                  type = types.port;
                  description = "The upper bound of the port range";
                };
              };
            };
            default = {
              from = 30000;
              to = 32767;
            };
            description = "The port range to use for service node ports. Only valid when serviceCIDR is set.";
          };
        };
      };
    perInstance =
      {
        instanceName,
        roles,
        mkExports,
        machine,
        settings,
        ...
      }:
      {
        nixosModule =
          {
            config,
            lib,
            pkgs,
            ...
          }:
          {
            imports = [
              (import ./server.nix {
                inherit
                  clanLib
                  instanceName
                  roles
                  config
                  lib
                  pkgs
                  mkExports
                  machine
                  settings
                  directory
                  ;
              })
              (
                if lib.lists.any (role: role == "agent") machine.roles then
                  { }
                else
                  (import ./shared.nix {
                    inherit
                      clanLib
                      instanceName
                      roles
                      config
                      lib
                      pkgs
                      mkExports
                      machine
                      settings
                      directory
                      ;
                  })
              )
            ];

            config = {
              # config
            };
          };

      };
  };

  roles.agent = {
    description = "K3s Agent";
    interface =
      { lib, ... }:
      with lib;
      {
        options = {
          extraFlags = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Extra flags to pass to k3s agent";
          };
          k3sApiPort = mkOption {
            type = types.port;
            default = 6443;
            description = "The port on which the k3s server will listen for API requests";
          };
          k3sAdvertisedApiPort = mkOption {
            type = types.port;
            default = 6443;
            description = "The port on which the k3s server will advertise for API requests";
          };
        };

      };
    perInstance =
      {
        instanceName,
        roles,
        mkExports,
        machine,
        settings,
        ...
      }:
      {
        nixosModule =
          {
            config,
            lib,
            pkgs,
            ...
          }:
          {
            imports = [
              (import ./agent.nix {
                inherit
                  clanLib
                  instanceName
                  roles
                  config
                  lib
                  pkgs
                  mkExports
                  machine
                  settings
                  directory
                  ;
              })
              (import ./shared.nix {
                inherit
                  clanLib
                  instanceName
                  roles
                  config
                  lib
                  pkgs
                  mkExports
                  machine
                  settings
                  directory
                  ;
              })
            ];

            config = {
              # config
            };
          };

      };
  };
}
