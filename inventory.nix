{
  self,
  inputs,
  customLib,
}: {
  meta = {
    name = "packer";
    description = "Minimal NixOS Packer Images and Scripts";
    domain = "pkr.ccc";
  };

  machines = {
    # AWS
    aws-ext4-aarch64.tags = ["aws" "ext4" "aarch64"];
    aws-ext4-x86_64.tags = ["aws" "ext4" "x86_64"];
    aws-zfs-aarch64.tags = ["aws" "zfs" "aarch64"];
    aws-zfs-x86_64.tags = ["aws" "zfs" "x86_64"];
    # Hetzner Cloud
    hcloud-ext4-aarch64.tags = ["hcloud" "ext4" "aarch64"];
    hcloud-ext4-x86_64.tags = ["hcloud" "ext4" "x86_64"];
    hcloud-zfs-aarch64.tags = ["hcloud" "zfs" "aarch64"];
    hcloud-zfs-x86_64.tags = ["hcloud" "zfs" "x86_64"];
  };

  instances = {
    # --- Importers --- #
    importer.roles.default = {
      tags = ["all"];
      extraModules = [
        self.nixosModules.default
        self.nixosModules.motd
      ];
    };

    zfs = {
      module.name = "importer";
      roles.default = {
        tags = ["zfs"];
        extraModules = [self.nixosModules.zfs];
      };
    };

    ext4 = {
      module.name = "importer";
      roles.default = {
        tags = ["ext4"];
        extraModules = [self.nixosModules.ext4];
      };
    };

    hcloud = {
      module.name = "importer";
      roles.default = {
        tags = ["hcloud"];
        extraModules = [self.nixosModules.hcloud];
      };
    };

    aws = {
      module.name = "importer";
      roles.default = {
        tags = ["aws"];
        extraModules = [self.nixosModules.aws];
      };
    };

    x86_64 = {
      module.name = "importer";
      roles.default = {
        tags = ["x86_64"];
        extraModules = [
          {
            nixpkgs.hostPlatform = "x86_64-linux";
          }
        ];
      };
    };

    aarch64 = {
      module.name = "importer";
      roles.default = {
        tags = ["aarch64"];
        extraModules = [
          {
            nixpkgs.hostPlatform = "aarch64-linux";
          }
        ];
      };
    };
  };
}
