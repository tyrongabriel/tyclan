{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myHome.kitty;
in
with lib;
{
  options.myHome.kitty = {
    enable = mkEnableOption "Enable Kitty Terminal Emulator";
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      shellIntegration.enableZshIntegration = true;
    };
  };
}
