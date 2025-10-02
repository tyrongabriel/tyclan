{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      inputs',
      #system,
      ...
    }:
    {
      devShells.default = pkgs.mkShell { packages = [ inputs'.clan-core.packages.clan-cli ]; };
    };
}
