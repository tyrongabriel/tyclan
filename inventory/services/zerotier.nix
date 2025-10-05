{ lib, ... }:
{
  instances = {
    zerotier = {
      # Replace with the name (string) of your machine that you will use as zerotier-controller
      # See: https://docs.zerotier.com/controller/
      # Deploy this machine first to create the network secrets
      roles.controller = {
        extraModules = [
          # ./zerotier-modules/default.nix
        ];
        machines."ncvps01" = { };
      };
      # Peers of the network
      # tags.all means 'all machines' will joined
      roles.peer = {
        extraModules = [
          # ./zerotier-modules/secret-ipv4.nix
        ];
        tags.all = { };
      };
    };
  };
}
