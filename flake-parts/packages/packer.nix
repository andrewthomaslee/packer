{...}: {
  # ------ Per-System ------ #
  perSystem = {pkgs, ...}: {
    packages = {
      # --- Packer JSON --- #
      # Hetzner Cloud
      hcloud-x86_64-pkr-json = pkgs.writeText "hcloud-x86_64.pkr.json" (builtins.toJSON {
        packer.required_plugins.hcloud = {
          version = ">= 1.0.0";
          source = "github.com/hetznercloud/hcloud";
        };

        variable = {
          hcloud_token = {
            type = "string";
            sensitive = true;
            description = "Hetzner Cloud API Token with Read/Write permissions";
            default = "\${env(\"HCLOUD_TOKEN\")}";
          };
          temp_pub_key = {
            type = "string";
            default = "\${env(\"PACKER_TEMP_PUB_KEY\")}";
          };
          temp_priv_key = {
            type = "string";
            default = "\${env(\"PACKER_TEMP_KEY\")}";
          };
        };

        source.hcloud.determinate_nixos = {
          token = "\${var.hcloud_token}";
          image = "debian-13";
          location = "hel1";
          server_type = "cpx42";
          ssh_username = "root";
          snapshot_name = "nixos-x86_64-${pkgs.lib.trivial.release}";
          snapshot_labels = {
            os = "nixos";
            distro = "determinate+clan";
            release = pkgs.lib.trivial.release;
            timestamp = "{{timestamp}}";
            system = "x86_64";
          };
        };

        build = {
          name = "determinate-nixos";
          sources = ["source.hcloud.determinate_nixos"];
          provisioner = [
            {
              shell.inline = [
                "mkdir -p /root/.ssh"
                "echo '\${var.temp_pub_key}' >> /root/.ssh/authorized_keys"
              ];
            }
            {
              shell-local.inline = [
                "clan machines install hcloud-x86_64 --target-host \${build.User}@\${build.Host} --update-hardware-config nixos-generate-config -i \${var.temp_priv_key} --host-key-check none --yes"
              ];
            }
          ];
        };
      });

      hcloud-aarch64-pkr-json = pkgs.writeText "hcloud-aarch64.pkr.json" (builtins.toJSON {
        packer.required_plugins.hcloud = {
          version = ">= 1.0.0";
          source = "github.com/hetznercloud/hcloud";
        };

        variable = {
          hcloud_token = {
            type = "string";
            sensitive = true;
            description = "Hetzner Cloud API Token with Read/Write permissions";
            default = "\${env(\"HCLOUD_TOKEN\")}";
          };
          temp_pub_key = {
            type = "string";
            default = "\${env(\"PACKER_TEMP_PUB_KEY\")}";
          };
          temp_priv_key = {
            type = "string";
            default = "\${env(\"PACKER_TEMP_KEY\")}";
          };
        };

        source.hcloud.determinate_nixos = {
          token = "\${var.hcloud_token}";
          image = "debian-13";
          location = "hel1";
          server_type = "cax31";
          ssh_username = "root";
          snapshot_name = "nixos-aarch64-${pkgs.lib.trivial.release}";
          snapshot_labels = {
            os = "nixos";
            distro = "determinate+clan";
            release = pkgs.lib.trivial.release;
            timestamp = "{{timestamp}}";
            system = "aarch64";
          };
        };

        build = {
          name = "determinate-nixos";
          sources = ["source.hcloud.determinate_nixos"];
          provisioner = [
            {
              shell.inline = [
                "mkdir -p /root/.ssh"
                "echo '\${var.temp_pub_key}' >> /root/.ssh/authorized_keys"
              ];
            }
            {
              shell-local.inline = [
                "clan machines install hcloud-aarch64 --target-host \${build.User}@\${build.Host} --update-hardware-config nixos-generate-config -i \${var.temp_priv_key} --host-key-check none --yes"
              ];
            }
          ];
        };
      });

      # Amazon Web Services
      aws-x86_64-pkr-json = pkgs.writeText "aws-x86_64.pkr.json" (builtins.toJSON {});
      aws-aarch64-pkr-json = pkgs.writeText "aws-aarch64.pkr.json" (builtins.toJSON {});
    };
  };
}
