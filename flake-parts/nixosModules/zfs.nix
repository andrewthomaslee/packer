{...}: {
  # ------ NixOS Modules ------ #
  flake.nixosModules.zfs = {
    config,
    lib,
    pkgs,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      zstd
      lz4
      gzip
      e2fsprogs
      xfsprogs
    ];

    # --- Boot --- #
    boot = {
      supportedFilesystems = ["zfs"];
      initrd.supportedFilesystems = ["zfs"];
      loader = {
        systemd-boot.enable = lib.mkDefault false;
        grub.zfsSupport = lib.mkDefault true;
      };
      zfs.forceImportRoot = lib.mkDefault false;
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
              size = "3G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
                extraArgs = ["-n" "ESP"];
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
          compression = "zstd-fast";
          acltype = "posixacl";
          xattr = "sa";
          atime = "off";
          refreservation = "2G";
        };
        datasets."nix/store" = {
          type = "zfs_fs";
          mountpoint = "/nix/store";
          options = {
            sync = "disabled";
            atime = "off";
            "com.sun:auto-snapshot" = "false";
          };
        };
      };
    };
  };
}
