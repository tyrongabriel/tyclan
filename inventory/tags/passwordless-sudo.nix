{ ... }:
{
  ### TEMPORARY !!! TO INCREASE DEV SPEED ###
  security.sudo.extraRules = [
    {
      users = [ "tyron" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
