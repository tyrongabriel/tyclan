{
  # Ensure this is unique among all clans you want to use.
  meta.name = "tyclan";
  meta.description = "Tyron's Clan";

  # templates = {
  #   disko = {
  #     uefi-8g-swap = {
  #       description = "A simple disk with UEFI boot and 8GB swap";
  #       path = ./templates/disk/uefi-8g-single-disk;
  #     };
  #   };
  # };

  inventory.machines = {
    # Define machines here.
    # jon = { };
    ncvps01 = {
      deploy.targetHost = "root@152.53.149.109";
    };
  };

  # Docs: See https://docs.clan.lol/reference/clanServices
  inventory.instances = {
    # Docs: https://docs.clan.lol/guides/getting-started/add-user/
    tyron-user = {
      module.name = "users";

      roles.default.tags.all = { }; # Adds to ALL machines

      roles.default.settings = {
        user = "tyron";
        groups = [
          "wheel" # Allow using 'sudo'
          "networkmanager" # Allows to manage network connections.
          "video" # Allows to access video devices.
          "input" # Allows to access input devices.
        ];
        share = true; # Share the password of the user across machines (wont be reprompted!)
      };
      # roles.default.extraModules = [ ./users/tyron/home.nix ];
    };

    # Docs: https://docs.clan.lol/reference/clanServices/admin/
    # Admin service for managing machines
    # This service adds a root password and SSH access.
    admin = {
      roles.default.tags.all = { };
      roles.default.settings.allowedKeys = {
        # Insert the public key that you want to use for SSH access.
        # All keys will have ssh access to all machines ("tags.all" means 'all machines').
        # Alternatively set 'users.users.root.openssh.authorizedKeys.keys' in each machine
        "admin-yoga" =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEqAq3GCuNXFc8mQL+H/czF0+pOlyQ4c4GILKUcrK0fZ 51530686+tyrongabriel@users.noreply.github.com";
      };
    };

    # Docs: https://docs.clan.lol/reference/clanServices/zerotier/
    # The lines below will define a zerotier network and add all machines as 'peer' to it.
    # !!! Manual steps required:
    #   - Define a controller machine for the zerotier network.
    #   - Deploy the controller machine first to initialize the network.
    zerotier = {
      # Replace with the name (string) of your machine that you will use as zerotier-controller
      # See: https://docs.zerotier.com/controller/
      # Deploy this machine first to create the network secrets
      roles.controller.machines."ltc01" = { };
      # Peers of the network
      # tags.all means 'all machines' will joined
      roles.peer.tags.all = { };
    };

    # Docs: https://docs.clan.lol/reference/clanServices/tor/
    # Tor network provides secure, anonymous connections to your machines
    # All machines will be accessible via Tor as a fallback connection method
    # tor = {
    #   roles.server.tags.nixos = { };
    # };
  };

  # Additional NixOS configuration can be added here.
  # machines/jon/configuration.nix will be automatically imported.
  # See: https://docs.clan.lol/guides/more-machines/#automatic-registration
  machines = {
    # jon = { config, ... }: {
    #   environment.systemPackages = [ pkgs.asciinema ];
    # };
  };
}
