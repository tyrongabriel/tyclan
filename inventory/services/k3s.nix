_: {
  instances.k3s = {
    module.name = "@tyclan/k3s";
    module.input = "self";
    roles.default.tags."k3s" = { };
  };
}
