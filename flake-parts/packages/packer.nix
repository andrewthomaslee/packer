{...}: {
  # ------ Per-System ------ #
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    # common variables
    inherit (lib.trivial) release;
    os = "nixos";
    distro = "determinate+clan";
    timestamp = "{{timestamp}}";

    # Hcloud common configuration
    hcloud = {
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
        ssh_username = "root";
        snapshot_labels = {
          inherit release os distro timestamp;
          system = "x86_64";
        };
      };
      build = {
        name = "determinate-nixos";
        sources = ["source.hcloud.determinate_nixos"];
      };
    };

    # To be used in build.provisioner
    copy-ssh-key = {
      shell.inline = [
        "mkdir -p /root/.ssh"
        "echo '\${var.temp_pub_key}' >> /root/.ssh/authorized_keys"
      ];
    };
  in {
    packages = {
      # --- Packer JSON --- #
      # Hetzner Cloud
      hcloud-x86_64-pkr-json = pkgs.writeText "hcloud-x86_64.pkr.json" (builtins.toJSON (lib.recursiveUpdate {
          source.hcloud.determinate_nixos = {
            server_type = "cpx42";
            snapshot_name = "nixos-x86_64-${release}-${timestamp}";
            snapshot_labels.system = "x86_64";
          };
          build.provisioner = [
            copy-ssh-key
            {
              shell-local.inline = [
                "clan machines install hcloud-x86_64 --target-host \${build.User}@\${build.Host} --update-hardware-config nixos-generate-config -i \${var.temp_priv_key} --host-key-check none --yes"
              ];
            }
          ];
        }
        hcloud));

      hcloud-aarch64-pkr-json = pkgs.writeText "hcloud-aarch64.pkr.json" (builtins.toJSON (lib.recursiveUpdate {
          source.hcloud.determinate_nixos = {
            server_type = "cax31";
            snapshot_name = "nixos-aarch64-${release}-${timestamp}";
            snapshot_labels.system = "aarch64";
          };
          build.provisioner = [
            copy-ssh-key
            {
              shell-local.inline = [
                "clan machines install hcloud-aarch64 --target-host \${build.User}@\${build.Host} --update-hardware-config nixos-generate-config -i \${var.temp_priv_key} --host-key-check none --yes"
              ];
            }
          ];
        }
        hcloud));

      # Amazon Web Services
      aws-x86_64-pkr-json = pkgs.writeText "aws-x86_64.pkr.json" (builtins.toJSON {});
      aws-aarch64-pkr-json = pkgs.writeText "aws-aarch64.pkr.json" (builtins.toJSON {});
    };
  };
}
