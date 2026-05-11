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

    temp-key-vars = {
      temp_pub_key = {
        type = "string";
        default = "\${env(\"PACKER_TEMP_PUB_KEY\")}";
      };
      temp_priv_key = {
        type = "string";
        default = "\${env(\"PACKER_TEMP_KEY\")}";
      };
    };

    # To be used in build.provisioner
    copy-ssh-key = {
      shell.inline = [
        "mkdir -p /root/.ssh"
        "echo '\${var.temp_pub_key}' >> /root/.ssh/authorized_keys"
      ];
    };

    # Hcloud common configuration
    hcloud = {
      packer.required_plugins.hcloud = {
        version = ">= 1.0.0";
        source = "github.com/hetznercloud/hcloud";
      };
      variable =
        {
          hcloud_token = {
            type = "string";
            sensitive = true;
            description = "Hetzner Cloud API Token with Read/Write permissions";
            default = "\${env(\"HCLOUD_TOKEN\")}";
          };
        }
        // temp-key-vars;
      source.hcloud.determinate_nixos = {
        token = "\${var.hcloud_token}";
        image = "debian-13";
        location = "hel1";
        ssh_username = "root";
        snapshot_labels = {
          inherit release os distro timestamp;
        };
      };
      build = {
        name = "determinate-nixos";
        sources = ["source.hcloud.determinate_nixos"];
      };
    };

    mkHcloudPkrJson = system: server_type:
      pkgs.writeText "hcloud-${system}.pkr.json" (builtins.toJSON (lib.recursiveUpdate hcloud {
        source.hcloud.determinate_nixos = {
          inherit server_type;
          snapshot_name = "nixos-${system}-${release}-${timestamp}";
          snapshot_labels.system = system;
        };
        build.provisioner = [
          copy-ssh-key
          {
            shell-local.inline = [
              "clan machines install hcloud-${system} --target-host \${build.User}@\${build.Host} --no-persist-state -i \${var.temp_priv_key} --host-key-check none --yes"
            ];
          }
        ];
      }));
  in {
    # --- Packer JSON --- #
    packages = {
      # --- Hetzner Cloud x86_64 --- #
      hcloud-x86_64-pkr-json = mkHcloudPkrJson "x86_64" "cpx42";
      # --- Hetzner Cloud aarch64 --- #
      hcloud-aarch64-pkr-json = mkHcloudPkrJson "aarch64" "cax31";

      # --- AWS x86_64 --- #
      aws-x86_64-pkr-json = pkgs.writeText "aws-x86_64.pkr.json" (builtins.toJSON {});
      # --- AWS aarch64 --- #
      aws-aarch64-pkr-json = pkgs.writeText "aws-aarch64.pkr.json" (builtins.toJSON {});
    };
  };
}
