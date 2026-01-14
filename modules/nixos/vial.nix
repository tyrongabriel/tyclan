{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.myNixOS.vial;
in
{
  options.myNixOS.vial = with lib; {
    enable = mkEnableOption "Enable vial keyboard software";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs.unstable; [
      vial
    ];

    services.udev.packages = with pkgs.unstable; [
      vial
      via
    ];

  };
}
