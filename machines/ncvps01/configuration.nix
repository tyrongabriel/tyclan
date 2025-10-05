{ pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    btop
  ];

  ## Networking ##
  networking = {
    ## Network name (Should match flake!) ##
    #hostName = "ncvps01";
    useDHCP = false; # VPS requires manual conf
    nameservers = [
      "8.8.8.8" # Google's public DNS
      "8.8.4.4" # Google's public DNS
      "1.1.1.1" # Cloudflare's public DNS
      "9.9.9.9" # Quad9 DNS
    ];
  };

  # Define the static network configuration for the 'ens3' interface
  networking.interfaces.ens3 = {
    # Set this to false to ensure no DHCP is used for this interface
    useDHCP = false;
    # Configure the IPv4 address and subnet mask
    ipv4.addresses = [
      {
        address = "152.53.149.109";
        prefixLength = 22;
      }
    ];
    # Configure the IPv6 address and prefix length
    ipv6.addresses = [
      {
        address = "2a00:11c0:47:195b::10"; # CHOOSE YOUR HOST ADDRESS in the subnet
        prefixLength = 64; # Your subnet's prefix length
      }
    ];
  };

  # Set the default gateway
  networking.defaultGateway = {
    address = "152.53.148.1";
    interface = "ens3";
  };
  networking.defaultGateway6 = {
    address = "fe80::1"; # Your VPS's provided gateway
    interface = "ens3";
  };

  networking.firewall.allowedTCPPorts = [ 80 ]; # For testing

  clan.core.settings.state-version.enable = true;
}
