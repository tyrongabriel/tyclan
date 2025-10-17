{ pkgs, ... }:
{
  # All k3s nodes should require manual updates!
  clan.deployment.requireExplicitUpdate = true;
  environment.systemPackages = with pkgs; [
    toybox # For testing
  ];
}
