{...}: {
  flake.nixosModules.aws = {
    modulesPath,
    lib,
    ...
  }:
    with lib; {
      imports = [
        (modulesPath + "/virtualisation/amazon-image.nix")
      ];

      disko.devices.disk.main.device = "/dev/xvda";
      boot.loader.grub.device = mkForce "nodev";

      networking.hostName = mkForce "";
    };
}
