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
    distro = "determinate-clan";
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
          inherit release os distro;
        };
      };
      build = {
        name = "determinate-nixos";
        sources = ["source.hcloud.determinate_nixos"];
      };
    };

    mkHcloudPkrJson = fs: system: let
      server_type =
        if system == "aarch64"
        then "cax31"
        else "cpx42";
    in
      pkgs.writeText "hcloud-${fs}-${system}.pkr.json" (builtins.toJSON (lib.recursiveUpdate hcloud {
        source.hcloud.determinate_nixos = {
          inherit server_type;
          snapshot_name = "nixos-${fs}-${system}-${release}-${timestamp}";
          snapshot_labels = {inherit fs system server_type;};
        };
        build.provisioner = [
          copy-ssh-key
          {
            shell-local.inline = [
              "clan machines install hcloud-${fs}-${system} --target-host \${build.User}@\${build.Host} --no-persist-state -i \${var.temp_priv_key} --host-key-check none --yes"
            ];
          }
        ];
      }));

    # AWS common configuration
    aws = {
      packer.required_plugins.amazon = {
        version = ">= 1.2.0";
        source = "github.com/hashicorp/amazon";
      };
      variable =
        {
          aws_access_key_id = {
            type = "string";
            sensitive = true;
            description = "AWS Access Key ID";
            default = "\${env(\"AWS_ACCESS_KEY_ID\")}";
          };
          aws_secret_access_key = {
            type = "string";
            sensitive = true;
            description = "AWS Secret Access Key";
            default = "\${env(\"AWS_SECRET_ACCESS_KEY\")}";
          };
          aws_region = {
            type = "string";
            description = "AWS Region";
            default = "\${env(\"AWS_REGION\")}";
          };
        }
        // temp-key-vars;
      source.amazon-ebs.determinate_nixos = {
        access_key = "\${var.aws_access_key_id}";
        secret_key = "\${var.aws_secret_access_key}";
        region = "\${var.aws_region}";
        ssh_username = "admin";
        tags = {
          inherit release os distro;
        };
      };
      build = {
        name = "determinate-nixos";
        sources = ["source.amazon-ebs.determinate_nixos"];
      };
    };

    mkAwsPkrJson = fs: system: let
      arch =
        if system == "aarch64"
        then "arm64"
        else "amd64";
      instance_type =
        if system == "aarch64"
        then "t4g.medium"
        else "t3.medium";
    in
      pkgs.writeText "aws-${fs}-${system}.pkr.json" (builtins.toJSON (lib.recursiveUpdate aws {
        source.amazon-ebs.determinate_nixos = {
          inherit instance_type;
          ami_name = "nixos-${fs}-${system}-${release}-${timestamp}";
          source_ami_filter = {
            filters = {
              name = "debian-13-${arch}-*";
              root-device-type = "ebs";
              virtualization-type = "hvm";
            };
            most_recent = true;
            owners = ["136693071363"];
          };
          tags = {inherit fs system instance_type;};
        };
        build.provisioner = [
          copy-ssh-key
          {
            shell-local.inline = [
              "clan machines install aws-${fs}-${system} --target-host \${build.User}@\${build.Host} --update-hardware-config nixos-generate-config -i \${var.temp_priv_key} --host-key-check none --yes"
            ];
          }
        ];
      }));
  in {
    # --- Packer JSON --- #
    packages = {
      # --- Hetzner Cloud --- #
      hcloud-zfs-x86_64-pkr-json = mkHcloudPkrJson "zfs" "x86_64";
      hcloud-zfs-aarch64-pkr-json = mkHcloudPkrJson "zfs" "aarch64";
      hcloud-ext4-x86_64-pkr-json = mkHcloudPkrJson "ext4" "x86_64";
      hcloud-ext4-aarch64-pkr-json = mkHcloudPkrJson "ext4" "aarch64";

      # --- AWS --- #
      aws-zfs-x86_64-pkr-json = mkAwsPkrJson "zfs" "x86_64";
      aws-zfs-aarch64-pkr-json = mkAwsPkrJson "zfs" "aarch64";
      aws-ext4-x86_64-pkr-json = mkAwsPkrJson "ext4" "x86_64";
      aws-ext4-aarch64-pkr-json = mkAwsPkrJson "ext4" "aarch64";
    };
  };
}
