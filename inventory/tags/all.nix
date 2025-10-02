{ pkgs, lib, ... }:
with lib;
{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    ports = [ 22 ];
    openFirewall = true;
  };
  #services.avahi.enable = true;
  nixpkgs.config.allowUnfree = true;
  clan.core.settings.state-version.enable = true;

  environment.systemPackages = with pkgs; [
    btop
  ];

  networking = {
    networkmanager.enable = true;
    useNetworkd = false;
  };
  # Set your time zone.
  time.timeZone = "Europe/Vienna"; # "Europe/Vienna";

  # For time format in windows dualboot
  time.hardwareClockInLocalTime = mkDefault true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_AT.UTF-8";
    LC_IDENTIFICATION = "de_AT.UTF-8";
    LC_MEASUREMENT = "de_AT.UTF-8";
    LC_MONETARY = "de_AT.UTF-8";
    LC_NAME = "de_AT.UTF-8";
    LC_NUMERIC = "de_AT.UTF-8";
    LC_PAPER = "de_AT.UTF-8";
    LC_TELEPHONE = "de_AT.UTF-8";
    LC_TIME = "de_AT.UTF-8";
  };

  console.useXkbConfig = true;
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "at";
    variant = "nodeadkeys";
    options = "caps:escape";
  };
}
