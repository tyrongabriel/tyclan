{ pkgs, inputs, ... }:
let
  filesIn = dir: (map (fname: dir + "/${fname}") (builtins.attrNames (builtins.readDir dir)));

  imports = builtins.filter (filePath: filePath != ./default.nix) (filesIn ./.);
in
{
  imports = [ ] ++ imports;

  # Needs to be here, flake-parts overlays module args,
  # but not the nixpkgs, which does NOT propagate the overlay
  # to home-manager, this does:
  nixpkgs.overlays = [
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    })
    (final: prev: {
      stable-25_11 = import inputs.nixpkgs-25_11 {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    })
  ];
}
