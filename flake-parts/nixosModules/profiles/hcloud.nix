{...}: {
  flake = {
    # ------ NixOS Modules ------ #
    nixosModules.hcloud = {lib, ...}: {
      disko.devices.disk.main.device = lib.mkForce "/dev/sda";
    };
  };
}
