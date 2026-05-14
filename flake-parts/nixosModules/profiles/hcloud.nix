{...}: {
  flake.nixosModules.hcloud = {modulesPath, ...}: {
    imports = [(modulesPath + "/profiles/qemu-guest.nix")];

    disko.devices.disk.main.device = "/dev/sda";

    boot.initrd.availableKernelModules = ["ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod"];

    networking.interfaces.enp1s0.useDHCP = true;
  };
}
