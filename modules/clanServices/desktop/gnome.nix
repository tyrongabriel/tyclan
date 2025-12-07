{
  roles.gnome.perInstance =
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
          config,
          lib,
          ...
        }:
        {
          # ---------- GNOME ----------
          services.xserver.enable = true;
          services.displayManager.gdm.enable = true;
          services.desktopManager.gnome.enable = true;
          environment.gnome.excludePackages = (
            with pkgs;
            [
              gnome-photos
              gnome-tour
              gnome-music
              cheese # webcam tool
              gedit # text editor
              epiphany # web browser
              geary # email reader
              gnome-characters
              tali # poker game
              iagno # go game
              hitori # sudoku game
              atomix # puzzle game
              yelp # Help view
              gnome-contacts
              gnome-initial-setup
              gnome-text-editor
            ]
          );
          # ++ (with pkgs.gnome; [ ] );
          programs.dconf.enable = true;

          # GDM Profile picture
          services.accounts-daemon.enable = true;
          environment.systemPackages = with pkgs; [
            gnome-tweaks
            dconf-editor
          ];

          #### ENV VARS FOR WAYLAND ####
          environment.variables = {
            # Force Wayland for apps that support it
            MOZ_ENABLE_WAYLAND = "1"; # For Firefox & Mozilla-based apps
            QT_QPA_PLATFORM = "wayland-egl"; # For Qt apps (Telegram, etc.)
            GDK_BACKEND = "wayland"; # For GTK apps
            SDL_VIDEODRIVER = "wayland"; # For SDL-based apps (Games, Emulators)
            CLUTTER_BACKEND = "wayland"; # Clutter-based apps (e.g., some GNOME apps)
            XDG_SESSION_TYPE = "wayland"; # Ensure session is Wayland
            XDG_CURRENT_DESKTOP = "gnome"; # Set your desktop environment explicitly

            # Electron and Chromium apps (VSCode, Brave, Discord, etc.)
            NIXOS_OZONE_WL = "1"; # Forces apps using XWayland to prefer Wayland
            # Enables Wayland for Electron apps
            ELECTRON_OZONE_PLATFORM_HINT = "auto"; # Ensures Electron apps use native Wayland
          };
        };

    };
}
