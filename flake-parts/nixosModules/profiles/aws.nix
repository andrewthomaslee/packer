{...}: {
  flake.nixosModules.aws = {modulesPath, ...}: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
    ];

    disko.devices.disk.main.device = "/dev/nvme0n1";

    boot.initrd.availableKernelModules = ["ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod"];

    networking.useDHCP = true;
  };
}
