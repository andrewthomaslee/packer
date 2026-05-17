{...}: {
  flake.nixosModules.hcloud = {
    modulesPath,
    lib,
    ...
  }: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
      (modulesPath + "/profiles/headless.nix")
    ];

    services.qemuGuest.enable = true;

    disko.devices.disk.main.device = "/dev/sda";

    boot.initrd.availableKernelModules = ["ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod"];

    networking.interfaces.enp1s0.useDHCP = true;

    # --- Boot --- #
    boot = {
      loader.grub = {
        efiInstallAsRemovable = lib.mkDefault true;
        efiSupport = lib.mkDefault true;
      };
      tmp = {
        useTmpfs = lib.mkDefault false;
        cleanOnBoot = lib.mkDefault true;
      };
    };
  };
}
