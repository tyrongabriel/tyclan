{
  roles.catppuccin.perInstance =
    {
      instanceName,
      settings,
      roles,
      machine,
      ...
    }:
    {
      nixosModule =
        {
          pkgs,
          lib,
          inputs,
          ...
        }:
        let
          catppuccin = {
            latte = {
              base00 = "eff1f5"; # base
              base01 = "e6e9ef"; # mantle
              base02 = "dce0e8"; # surface0
              base03 = "bcc0cc"; # surface1
              base04 = "acb0be"; # surface2
              base05 = "4c4f69"; # text
              base06 = "dd7878"; # rosewater
              base07 = "8839ef"; # lavender
              base08 = "d20f39"; # red
              base09 = "fe640b"; # peach
              base0A = "df8e1d"; # yellow
              base0B = "40a02b"; # green
              base0C = "179299"; # teal
              base0D = "1e66f5"; # blue
              base0E = "ea76cb"; # mauve
              base0F = "e64553"; # flamingo
            };
            frappe = {
              base00 = "303446"; # base
              base01 = "292c3c"; # mantle
              base02 = "414559"; # surface0
              base03 = "51576d"; # surface1
              base04 = "626880"; # surface2
              base05 = "c6d0f5"; # text
              base06 = "f2d5cf"; # rosewater
              base07 = "babbf1"; # lavender
              base08 = "e78284"; # red
              base09 = "ef9f76"; # peach
              base0A = "e5c890"; # yellow
              base0B = "a6d189"; # green
              base0C = "81c8be"; # teal
              base0D = "8caaee"; # blue
              base0E = "ca9ee6"; # mauve
              base0F = "eebebe"; # flamingo
            };
            macchiato = {
              base00 = "24273a"; # base
              base01 = "1e2030"; # mantle
              base02 = "363a4f"; # surface0
              base03 = "494d64"; # surface1
              base04 = "5b6078"; # surface2
              base05 = "cad3f5"; # text
              base06 = "f4dbd6"; # rosewater
              base07 = "b7bdf8"; # lavender
              base08 = "ed8796"; # red
              base09 = "f5a97f"; # peach
              base0A = "eed49f"; # yellow
              base0B = "a6da95"; # green
              base0C = "8bd5ca"; # teal
              base0D = "8aadf4"; # blue
              base0E = "c6a0f6"; # mauve
              base0F = "f0c6c6"; # flamingo
            };
            mocha = {
              base00 = "1e1e2e"; # base
              base01 = "181825"; # mantle
              base02 = "313244"; # surface0
              base03 = "45475a"; # surface1
              base04 = "585b70"; # surface2
              base05 = "cdd6f4"; # text
              base06 = "f5e0dc"; # rosewater
              base07 = "b4befe"; # lavender
              base08 = "f38ba8"; # red
              base09 = "fab387"; # peach
              base0A = "f9e2af"; # yellow
              base0B = "a6e3a1"; # green
              base0C = "94e2d5"; # teal
              base0D = "89b4fa"; # blue
              base0E = "cba6f7"; # mauve
              base0F = "f2cdcd"; # flamingo
            };
          };
        in
        {
          imports = [ inputs.stylix.nixosModules.stylix ];
          # ---------- Stylix ----------
          stylix = {
            enable = lib.mkDefault true;

            # The whole nixpkgs.config while using useGlobalPkgs:
            # https://github.com/danth/stylix/issues/865
            # https://github.com/nix-community/home-manager/pull/6172#issuecomment-2661425250
            # https://github.com/brckd/stylix/commit/ce6e96cbd88dcbc22e411120455b23bd3cdd5963
            # This will soon enable:
            # overlays.enable = false;
            polarity = "dark";
            image = ../../../assets/wallpapers/waterfall.png;

            base16Scheme = catppuccin."${settings.flavor}";

            fonts = {
              monospace = {
                package = pkgs.nerd-fonts.jetbrains-mono;
                name = "JetBrainsMono Nerd Font Mono";
              };
              sansSerif = {
                package = pkgs.dejavu_fonts;
                name = "DejaVu Sans";
              };
              serif = {
                package = pkgs.dejavu_fonts;
                name = "DejaVu Serif";
              };

              # TODO: Add support to change sizes based on device!
              sizes = {
                applications = 12;
                terminal = 12;
                desktop = 10;
                popups = 10;
              };
            };

            targets.chromium.enable = true;
            targets.grub.enable = true;
            targets.grub.useWallpaper = true;
            targets.plymouth.enable = true;
            #targets.opencode.enable = false;
            #targets.gnome-text-editor.enable = false;

            autoEnable = true;

            # See https://github.com/NixOS/nixpkgs/blob/88a55dffa4d44d294c74c298daf75824dc0aafb5/pkgs/by-name/bi/bibata-cursors/package.nix#L61
            # For available cursor names
            cursor.name = "Bibata-Modern-Ice";
            cursor.package = pkgs.bibata-cursors;
            cursor.size = 24;
          };

          ### Home-Manager ###
          # home-manager.sharedModules = [
          #   ./home.nix
          # ];
        };
    };
}
