{...}: {
  flake.nixosModules.aws = {
    modulesPath,
    lib,
    ...
  }: {
    imports = [
      (modulesPath + "/virtualisation/amazon-image.nix")
    ];

    disko.devices.disk.main.device = "/dev/nvme0n1";
    boot.loader.grub.device = lib.mkForce "nodev";
  };
}
