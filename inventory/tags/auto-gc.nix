{
  ...
}:
{
  config = {
    nix.gc = {
      automatic = true;
      dates = "daily";
      randomizedDelaySec = "1h";
      options = "--delete-older-than 7d";
    };

    nix.optimise = {
      automatic = true;
      dates = "weekly";
      randomizedDelaySec = "1h";
    };
  };
}
