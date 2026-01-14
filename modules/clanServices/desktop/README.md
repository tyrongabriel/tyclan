# Clan Services Desktop

This module provides desktop environment options for your NixOS clan machines.

## Available Desktop Environments

### GNOME

The GNOME desktop environment is a graphical user interface that provides a complete desktop experience with applications, system utilities, and a modern interface.

To enable GNOME:
1. Tag your machine with `gnome` in the inventory
2. Optionally configure `usesStylix` setting if using stylix

Example inventory configuration:
```nix
roles.gnome.tags = [ "gnome" ];
roles.gnome.machines."machine-name".settings.usesStylix = true;
```

### COSMIC

COSMIC is a desktop environment developed in Rust for Wayland. It provides a modern, customizable desktop experience with a focus on performance and simplicity.

To enable COSMIC:
1. Tag your machine with `cosmic` in the inventory
2. Optionally configure `usesStylix` setting if using stylix

Example inventory configuration:
```nix
roles.cosmic.tags = [ "cosmic" ];
roles.cosmic.machines."machine-name".settings.usesStylix = true;
```

#### COSMIC Features

- Built with Rust and the iced GUI library
- Uses Smithay for its compositor (cosmic-comp)
- Provides a modern, clean desktop interface
- Optimized for Wayland
- Includes a custom suite of applications

#### Optional COSMIC Configuration

You can customize COSMIC by adding additional options to your machine configuration:

```nix
# Exclude specific COSMIC applications
environment.cosmic.excludePackages = with pkgs; [
  cosmic-edit
];

# Enable performance optimizations
services.system76-scheduler.enable = true;

# Enable clipboard management (security trade-off)
environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = "1";

# Firefox theming fix
programs.firefox.preferences = {
  "widget.gtk.libadwaita-colors.enabled" = false;
};
```
