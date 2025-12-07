# Goto: https://git.clan.lol/adeci/clan-core/src/branch/adeci-stable/clanServices/roster/default.nix
{ ... }:
let
  roster-users = {
    tyron = {
      description = "Tyron";
      defaultUid = 3801;
      defaultGroups = [
        "networkmanager"
        "video"
        "audio"
        "input"
        "kvm"
      ];
      sshAuthorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEqAq3GCuNXFc8mQL+H/czF0+pOlyQ4c4GILKUcrK0fZ 51530686+tyrongabriel@users.noreply.github.com"
      ];
      defaultPosition = "owner"; # Password generating admin
      defaultShell = "zsh";
    };
  };

  roster-machines = {

    # ========== Tyron Machines ===========
    yoga = {
      users = {
        tyron = {
          homeManager = {
            enable = true;
            profiles = [
              "base"
              "stylix" # Needs to be enabled for all machines using stylix, since it depends on home-manager options
            ];
          };
        };
      };
      # homeManagerOptions = {
      #   sharedModules = [
      #     {
      #       wayland.windowManager.hyprland.settings.monitor = [
      #         "eDP-1,2880x1920@120,auto,2"
      #         "DP-3,preferred,auto,1,mirror,eDP-1"
      #       ];
      #     }
      #   ];
      # };
    };
    ncvps01 = {
      users = {
        tyron = {
          homeManager = {
            enable = true;
            profiles = [
              "base"
            ];
          };
        };
      };
      # homeManagerOptions = {
      #   sharedModules = [
      #     {
      #       wayland.windowManager.hyprland.settings.monitor = [
      #         "eDP-1,2880x1920@120,auto,2"
      #         "DP-3,preferred,auto,1,mirror,eDP-1"
      #       ];
      #     }
      #   ];
      # };
    };

    ncvps02 = {
      users = {
        tyron = {
          homeManager = {
            enable = true;
            profiles = [
              "base"
            ];
          };
        };
      };
      homeManagerOptions = {
        sharedModules = [
          # {
          #   wayland.windowManager.hyprland.settings.monitor = [
          #     "eDP-1,2880x1920@120,auto,2"
          #     "DP-3,preferred,auto,1,mirror,eDP-1"
          #   ];
          # }
        ];
      };
    };

    ltc01 = {
      users = {
        tyron = {
          homeManager = {
            enable = true;
            profiles = [
              "base"
            ];
          };
        };
      };
    };

    hp01 = {
      users = {
        tyron = {
          homeManager = {
            enable = true;
            profiles = [
              "base"
            ];
          };
        };
      };
    };
  };
in
{
  instances = {
    roster = {
      module.name = "@tyclan/roster";
      module.input = "self";
      roles.default.tags.all = { };
      roles.default.settings = {
        users = roster-users;
        machines = roster-machines;
        homeProfilesPath = ../home-profiles;

        homeManagerOptions = {
          sharedModules = [
            ../../modules/home-manager/default.nix
          ];
          backupFileExtension = "bak";
        };
      };
    };
  };
}
