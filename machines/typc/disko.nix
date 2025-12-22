{ lib, ... }:
{
  ## Boot Config ##
  boot = {
    #kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = lib.mkForce [ "btrfs" ]; # Force support for my used filesystem

    ## Bootloader ##
    # TODO: Fit into a module!
    loader.grub = {
      # no need to set devices, disko will add all devices that have a EF02 partition to the list already
      # devices = [ ];
      # device = "nodev"; # No specific partition
      # useOSProber = true; # Autodetect windows
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
  };

  disko.devices = {
    disk = {
      sda = {
        type = "disk";
        # The storage device
        device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_500GB_S4EVNF0M877678H";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "boot";
              size = "1M";
              type = "EF02";
            };
            # Boot Partition
            ESP = {
              label = "boot";
              name = "ESP";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "defaults" ];
              };
            };
            # Root partition (In the future, impermanent!)
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-L"
                  "nixos"
                  "-f"
                ]; # Label it nixos
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "subvol=root"
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "subvol=home"
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "subvol=nix"
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/log" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "subvol=log"
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  # "/swap" = {
                  #   mountpoint = "/swap";
                  #   swap.swapfile.size = "8G";
                  # };
                };
              };
            };
          };
        };
      };

      sdb = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD10EZEX-21WN4A0_WCC6Y4LJKT95";
        content = {
          type = "gpt";
          partitions = {
            userdata = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-L"
                  "userdata"
                  "-f"
                ]; # Label it userdata
                subvolumes = {
                  "/tyron-sdb" = {
                    mountpoint = "/home/tyron/sdb";
                    mountOptions = [
                      "subvol=tyron-sdb"
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  fileSystems."/var/log".neededForBoot = true;

  systemd.tmpfiles.rules = [
    "d /home/tyron/sdb 0755 tyron users -"
  ];
}
