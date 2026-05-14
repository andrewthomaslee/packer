{...}: {
  flake.nixosModules.aws = {
    modulesPath,
    lib,
    ...
  }:
    with lib; {
      imports = [(modulesPath + "/virtualisation/amazon-image.nix")];

      disko.devices.disk.main.device = "/dev/nvme0n1";

      boot.initrd.availableKernelModules = ["nvme"];

      networking = {
        hostName = mkForce "";
        interfaces.ens5.useDHCP = true;
      };

      services.udisks2.enable = mkForce false;
    };
}
