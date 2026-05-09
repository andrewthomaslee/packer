{self, ...}: {
  # ------ Per-System ------ #
  perSystem = {...}: {
    packages = {
      hcloud = self.nixosConfigurations.hcloud.config.system.build.toplevel;
      aws = self.nixosConfigurations.aws.config.system.build.toplevel;
    };
  };
}
