{ pkgs, ... }:
{
  programs.bat.enable = true;
  programs.bat.package = pkgs.unstable.bat;
}
