{ pkgs, lib, ... }:
let
  filesIn = dir: (map (fname: dir + "/${fname}") (builtins.attrNames (builtins.readDir dir)));
  imports = builtins.filter (filePath: filePath != ./default.nix) (filesIn ./system);
in
{
  import = [ ] ++ imports;
  environment.systemPackages = with pkgs; [
    btop
  ];

  ## Networking ##
  networking = {
    ## Network name (Should match flake!) ##
    useDHCP = true; # VPS requires manual conf
    nameservers = [
      "8.8.8.8" # Google's public DNS
      "8.8.4.4" # Google's public DNS
      "1.1.1.1" # Cloudflare's public DNS
      "9.9.9.9" # Quad9 DNS
    ];
    networkmanager.enable = true;
  };

  clan.core.settings.state-version.enable = true;
}
