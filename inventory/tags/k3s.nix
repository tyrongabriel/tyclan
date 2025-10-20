{ pkgs, lib, ... }:
{
  # All k3s nodes should require manual updates!
  clan.core.deployment.requireExplicitUpdate = lib.mkDefault true;
  environment.systemPackages = with pkgs; [
    toybox # For testing
  ];
}
