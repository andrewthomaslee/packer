{...}: {
  flake.nixosModules.aws = {
    modulesPath,
    lib,
    ...
  }:
    with lib; {
      imports = [(modulesPath + "/virtualisation/amazon-image.nix")];

      networking = {
        hostName = mkForce "";
        interfaces.ens5.useDHCP = true;
      };

      services.udisks2.enable = mkForce false;
    };
}
