{...}: {
  # ------ NixOS Modules ------ #
  flake.nixosModules.ext4 = {lib, ...}: {
    # --- Disko Partitions --- #
    disko.devices.disk = {
      main = {
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
              priority = 2;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077" "noatime"];
              };
            };
            nixos = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                mountOptions = ["noatime"];
              };
            };
          };
        };
      };
    };
  };
}
