# NixOS module to import home-manager and the home-manager configuration of 'tyron'
{ self, ... }:
{
  imports = [ self.inputs.home-manager.nixosModules.default ];
  home-manager.users.tyron = {
    imports = [
      ./home.nix
    ];
  };
}
