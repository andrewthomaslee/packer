{...}: {
  flake.nixosModules.aws = {...}: {
    disko.devices.disk.main.device = "/dev/nvme0n1";

    boot.initrd.availableKernelModules = ["nvme"];

    networking.interfaces.ens5.useDHCP = true;
  };
}
