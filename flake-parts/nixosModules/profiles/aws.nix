{...}: {
  flake.nixosModules.aws = {lib, ...}: {
    disko.devices.disk.main.device = "/dev/nvme0n1";

    boot.initrd.availableKernelModules = ["ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" "nvme"];

    networking.useDHCP = true;
    networking.interfaces.ens5.useDHCP = lib.mkDefault true;
  };
}
