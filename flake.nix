{
  inputs = {
    ## Clan Core ##
    clan-core.url = "https://git.clan.lol/clan/clan-core/archive/main.tar.gz";
    nixpkgs.follows = "clan-core/nixpkgs"; # Points to a stable, audited version of nixpkgs!

    ## Flake-Parts (With clan) ##
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "clan-core/nixpkgs";

    ## Custom Nixpkgs Versions ##
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-25_05.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      imports = [
        inputs.clan-core.flakeModules.default
      ];

      # https://docs.clan.lol/guides/getting-started/flake-parts/
      clan = {
        specialArgs = {
          pkgs-unstable = inputs.nixpkgs-unstable;
          pkgs-25_05 = inputs.nixpkgs-25_05;

        };
        imports = [ ./clan.nix ];
      };

      perSystem =
        {
          pkgs,
          inputs',
          system,
          ...
        }:
        {
          devShells.default = pkgs.mkShell { packages = [ inputs'.clan-core.packages.clan-cli ]; };
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              #inputs.foo.overlays.default
              # (final: prev: {
              #   # ... things you need to patch ...
              # })
              (final: prev: {
                v25_05 = import inputs.nixpkgs-25_05 {
                  inherit (prev) system;
                  config = {
                    allowUnfree = true;
                  };
                };
                unstable = import inputs.nixpkgs-unstable {
                  inherit (prev) system;
                  config = {
                    allowUnfree = true;
                  };
                };
              })
            ];
            config = { };
          };
        };
    };
}
