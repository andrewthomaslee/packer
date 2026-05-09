{
  modulesPath,
  self,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    self.nixosModules.default
    self.nixosModules.hcloud
  ];

  boot.initrd.availableKernelModules = ["ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod"];

  networking.interfaces = {
    enp1s0.useDHCP = true;
    enp7s0.useDHCP = true;
  };
}
