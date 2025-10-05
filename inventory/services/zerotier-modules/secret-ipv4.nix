{
  lib,
  config,
  pkgs,
  ...
}:
{
  clan.core.vars.generators.zerotier-ipv4 = {
    files.zerotier-ipv4.secret = false;
    files.zerotier-ipv4.restartUnits = [ "zerotierone.service" ];
    runtimeInputs = [
      config.services.zerotierone.package
      pkgs.jq
    ];
    script = ''
      zerotier-cli listnetworks -j | jq -r '.[].assignedAddresses[]? | select(test("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}/"))' | cut -d/ -f1
    '';

  };

  clan.core.state.zerotier-ipv4.folders = [ "/var/lib/zerotier-one" ];

}
