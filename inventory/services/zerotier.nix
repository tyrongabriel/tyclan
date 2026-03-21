{ lib, ... }:
{
  instances = {
    zerotier = {
      # Replace with the name (string) of your machine that you will use as zerotier-controller
      # See: https://docs.zerotier.com/controller/
      # Deploy this machine first to create the network secrets
      roles.controller.machines."ncvps01" = {
        settings.allowedIps = [ "fd18:699:9430:6c57:99:9300:a012:3111" ];
      };
      roles.moon.machines."ncvps01" = {
        settings.stableEndpoints = [
          "152.53.149.109/9993"
          "2a00:11c0:47:195b::10/9993"
        ];
      };

      # Peers of the network
      # tags.all means 'all machines' will joined
      roles.peer.tags.all = { };
    };
  };
}
