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
    aws-aarch64.tags = ["aws" "aarch64"];
    aws-x86_64.tags = ["aws" "x86_64"];
    # Hetzner Cloud
    hcloud-aarch64.tags = ["hcloud" "aarch64"];
    hcloud-x86_64.tags = ["hcloud" "x86_64"];
  };

  instances = {
    # --- Importers --- #
    importer.roles.default = {
      tags = ["all"];
      extraModules = [
        self.nixosModules.default
        self.nixosModules.motd
        self.nixosModules.zfs
      ];
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
