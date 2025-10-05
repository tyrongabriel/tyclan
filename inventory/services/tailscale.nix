_: {
  instances.tailscale-net = {
    module.name = "@tyclan/tailscale";
    module.input = "self";

    roles.peer.tags.all = { };
  };
}
