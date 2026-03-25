_: {
  instances = {
    authentik = {
      module.name = "@tyclan/authentik";
      module.input = "self";
      roles.default.machines."ncvps01".settings = {
        domain = "ncvps01.tail1c2108.ts.net";
        email = "admin@example.com";
        image = "ghcr.io/goauthentik/server";
        tag = "2026.2.1";
        externalPort = 9000;
      };
    };
  };
}
