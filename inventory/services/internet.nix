_: {
  instances = {
    internet = {
      roles.default.machines = {
        ncvps01.settings = {
          host = "152.53.149.109";
          user = "tyron";
        };
        ncvps02.settings = {
          host = "159.195.9.89";
          user = "tyron";
        };
        ltc01.settings = {
          host = "192.168.8.10";
          user = "tyron";
        };
        hp01.settings = {
          host = "192.168.8.11";
          user = "tyron";
        };
        yoga.settings = {
          host = "localhost";
          user = "tyron";
        };
        typc.settings = {
          host = "192.168.1.138";
          user = "tyron";
        };
      };
    };
  };
}
