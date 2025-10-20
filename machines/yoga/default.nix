{ pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    btop
  ];

  ## Networking ##
  networking = {
    ## Network name (Should match flake!) ##
    #hostName = "ncvps01";
    useDHCP = true; # VPS requires manual conf
    nameservers = [
      "8.8.8.8" # Google's public DNS
      "8.8.4.4" # Google's public DNS
      "1.1.1.1" # Cloudflare's public DNS
      "9.9.9.9" # Quad9 DNS
    ];
  };

  clan.core.settings.state-version.enable = true;
}
