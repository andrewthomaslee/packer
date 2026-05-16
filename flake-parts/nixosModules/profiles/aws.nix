{...}: {
  flake.nixosModules.aws = {
    modulesPath,
    lib,
    config,
    ...
  }:
    with lib; {
      imports = [
        (modulesPath + "/virtualisation/amazon-image.nix")
      ];

      disko.devices.disk.main.device = "/dev/nvme0n1";
      boot.loader.grub.device = mkForce "nodev";

      networking.hostName = mkForce config.clan.core.settings.machine.name; # use clan name
    };
}
