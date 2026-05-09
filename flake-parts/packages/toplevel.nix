{self, ...}: {
  # ------ Per-System ------ #
  perSystem = {...}: {
    packages = {
      hcloud-x86_64 = self.nixosConfigurations.hcloud-x86_64.config.system.build.toplevel;
      hcloud-aarch64 = self.nixosConfigurations.hcloud-aarch64.config.system.build.toplevel;
      aws-x86_64 = self.nixosConfigurations.aws-x86_64.config.system.build.toplevel;
      aws-aarch64 = self.nixosConfigurations.aws-aarch64.config.system.build.toplevel;
    };
  };
}
