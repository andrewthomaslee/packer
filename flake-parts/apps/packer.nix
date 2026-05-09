{self, ...}: {
  # ------ Per-System ------ #
  perSystem = {
    pkgs,
    lib,
    self',
    inputs',
    ...
  }: let
    type = "app";
    runtimeInputs = with pkgs; [
      coreutils
      bash
      inputs'.clan-core.packages.clan-cli
      packer
      bun
    ];
    pre-text = ''
      export REPO_ROOT
      REPO_ROOT=${self}
      export CLAN_DIR
      CLAN_DIR="$REPO_ROOT"

      # Generate a temporary SSH key
      TEMP_KEY_DIR=$(mktemp -d)
      ssh-keygen -t ed25519 -f "$TEMP_KEY_DIR/id_ed25519" -N "" -q
      PACKER_TEMP_KEY="$TEMP_KEY_DIR/id_ed25519"
      export PACKER_TEMP_KEY
      PACKER_TEMP_PUB_KEY="$(cat "$TEMP_KEY_DIR/id_ed25519.pub")"
      export PACKER_TEMP_PUB_KEY

      # Cleanup on exit
      trap 'rm -rf "$TEMP_KEY_DIR"' EXIT

      eval "$(bunx varlock load --format shell)"
    '';
  in {
    apps = {
      packer-hcloud-x86_64 = {
        inherit type;
        program = lib.getExe (pkgs.writeShellApplication {
          inherit runtimeInputs;
          name = "packer-hcloud-x86_64";
          text =
            pre-text
            + ''
              packer init ${self'.packages.hcloud-x86_64-pkr-json}
              packer build ${self'.packages.hcloud-x86_64-pkr-json}
            '';
        });
      };
      packer-hcloud-aarch64 = {
        inherit type;
        program = lib.getExe (pkgs.writeShellApplication {
          inherit runtimeInputs;
          name = "packer-hcloud-aarch64";
          text =
            pre-text
            + ''
              packer init ${self'.packages.hcloud-aarch64-pkr-json}
              packer build ${self'.packages.hcloud-aarch64-pkr-json}
            '';
        });
      };
      packer-aws-x86_64 = {
        inherit type;
        program = lib.getExe (pkgs.writeShellApplication {
          inherit runtimeInputs;
          name = "packer-aws-x86_64";
          text =
            pre-text
            + ''
              packer init ${self'.packages.aws-x86_64-pkr-json}
              packer build ${self'.packages.aws-x86_64-pkr-json}
            '';
        });
      };
      packer-aws-aarch64 = {
        inherit type;
        program = lib.getExe (pkgs.writeShellApplication {
          inherit runtimeInputs;
          name = "packer-aws-aarch64";
          text =
            pre-text
            + ''
              packer init ${self'.packages.aws-aarch64-pkr-json}
              packer build ${self'.packages.aws-aarch64-pkr-json}
            '';
        });
      };
    };
  };
}
