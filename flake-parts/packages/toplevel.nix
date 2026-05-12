{self, ...}: {
  # ------ Per-System ------ #
  perSystem = {...}: {
    packages = {
      # Hcloud
      hcloud-zfs-x86_64 = self.nixosConfigurations.hcloud-x86_64.config.system.build.toplevel;
      hcloud-zfs-aarch64 = self.nixosConfigurations.hcloud-aarch64.config.system.build.toplevel;
      hcloud-ext4-x86_64 = self.nixosConfigurations.hcloud-x86_64.config.system.build.toplevel;
      hcloud-ext4-aarch64 = self.nixosConfigurations.hcloud-aarch64.config.system.build.toplevel;
      # AWS
      aws-zfs-x86_64 = self.nixosConfigurations.aws-x86_64.config.system.build.toplevel;
      aws-zfs-aarch64 = self.nixosConfigurations.aws-aarch64.config.system.build.toplevel;
      aws-ext4-x86_64 = self.nixosConfigurations.aws-x86_64.config.system.build.toplevel;
      aws-ext4-aarch64 = self.nixosConfigurations.aws-aarch64.config.system.build.toplevel;
    };
  };
}
