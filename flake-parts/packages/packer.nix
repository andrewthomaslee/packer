{self, ...}: {
  # ------ Per-System ------ #
  perSystem = {system, ...}: {
    packages = {
      # hcloud = self.nixosConfigurations.${system}.hcloud.config.system.build.toplevel;
      # aws = self.nixosConfigurations.${system}.aws.config.system.build.toplevel;
    };
  };
}
