_: {
  instances.tailscale-net = {
    module.name = "@tyclan/tailscale";
    module.input = "self";

    roles.peer = {
      settings.sshUser = "tyron";
      settings.enableSSH = false; # No root login!
      tags.all = { };
    };
  };
}
