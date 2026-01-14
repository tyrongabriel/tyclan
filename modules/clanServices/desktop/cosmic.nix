{ clanLib, ... }:
{
  roles.cosmic.perInstance =
    {
      instanceName,
      settings,
      roles,
      machine,
      exports,
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
          # ---------- COSMIC ----------
          services.displayManager.cosmic-greeter.enable = true;
          services.desktopManager.cosmic.enable = true;

          # You can exclude certain COSMIC packages if needed
          # environment.cosmic.excludePackages = with pkgs; [
          #   cosmic-edit
          # ];

          # Optional performance optimization
          services.system76-scheduler.enable = true;

          # Optional: Enable clipboard management with security trade-off
          # environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = "1";

          # Optional: Firefox theming fix for COSMIC
          programs.firefox.preferences = {
            # disable libadwaita theming for Firefox
            "widget.gtk.libadwaita-colors.enabled" = false;
          };

          # Environment variables for COSMIC
          environment.variables = {
            # Set desktop environment explicitly
            XDG_CURRENT_DESKTOP = "COSMIC";
            XDG_SESSION_TYPE = "wayland";

            # Force Wayland for apps that support it
            MOZ_ENABLE_WAYLAND = "1"; # For Firefox & Mozilla-based apps
            QT_QPA_PLATFORM = "wayland-egl"; # For Qt apps
            GDK_BACKEND = "wayland"; # For GTK apps
            SDL_VIDEODRIVER = "wayland"; # For SDL-based apps (Games, Emulators)

            # Electron and Chromium apps (VSCode, Brave, Discord, etc.)
            NIXOS_OZONE_WL = "1"; # Forces apps using XWayland to prefer Wayland
            ELECTRON_OZONE_PLATFORM_HINT = "auto"; # Ensures Electron apps use native Wayland
          };

          # Stylix compatibility
          stylix.targets = lib.mkIf settings.usesStylix {
            qt.enable = false;
          };
        };
    };
}
