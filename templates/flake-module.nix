{ ... }:
{
  clan = {
    inherit (((import ./flake.nix).outputs { }).clan) templates;
  };
}
