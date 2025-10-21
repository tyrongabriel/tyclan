_: {
  instances.netbird = {
    module.name = "@tyclan/netbird";
    module.input = "self";

    roles.peer = {
      settings.sshUser = "tyron";
      tags.netbird = { };
    };
  };
}
