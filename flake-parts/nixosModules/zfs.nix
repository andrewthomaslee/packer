{...}: {
  # ------ NixOS Modules ------ #
  flake.nixosModules.zfs = {
    config,
    lib,
    pkgs,
    ...
  }: {
    environment.systemPackages = with pkgs; [zstd];

    systemd.tmpfiles.rules = [
      "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
    ];

    networking.hostId = "4e98920d"; # Must be unique after installation

    # --- Boot --- #
    boot = {
      supportedFilesystems = ["zfs"];
      initrd.supportedFilesystems = ["zfs"];
      loader = {
        systemd-boot.enable = lib.mkDefault false;
        grub = {
          enable = lib.mkDefault true;
          efiInstallAsRemovable = lib.mkDefault true;
          zfsSupport = lib.mkDefault true;
          efiSupport = lib.mkDefault true;
        };
      };
      zfs.forceImportRoot = lib.mkDefault false;
      tmp = {
        useTmpfs = lib.mkDefault false;
        cleanOnBoot = lib.mkDefault true;
      };
    };

    # --- ZFS --- #
    services.zfs = {
      autoScrub = {
        enable = lib.mkDefault true;
        interval = lib.mkDefault "weekly";
      };
      autoSnapshot = {
        enable = lib.mkDefault false;
        flags = lib.mkDefault "-k -p --utc";
      };
      trim = {
        enable = lib.mkDefault true;
        interval = lib.mkDefault "weekly";
      };
    };

    # --- Disko Partitions --- #
    disko.devices = {
      disk.main = {
        type = "disk";
        device = lib.mkDefault "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "10M";
              type = "EF02";
              priority = 1;
            };
            ESP = {
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
      zpool.zroot = {
        type = "zpool";
        mountpoint = "/";
        rootFsOptions = {
          compression = "zstd";
          acltype = "posixacl";
          xattr = "sa";
          atime = "off";
          refreservation = "1G";
        };
      };
    };
  };
}
