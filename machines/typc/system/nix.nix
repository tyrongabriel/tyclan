{
  inputs,
  lib,
  config,
  #outputs,
  ...
}:
{
  nix = {
    # Nix path
    nixPath = [
      "nixpkgs=${inputs.nixpkgs}" # Recommended for nixd
    ];
  };

  # Auto garbage collect
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  # Automatic store-optimization
  nix.optimise = {
    automatic = true;
    dates = [ "daily" ];
  };
}
