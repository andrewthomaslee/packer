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
      REPO_ROOT=$(git rev-parse --show-toplevel)
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
    apps = let
      packerPackages = lib.filterAttrs (name: _: lib.hasSuffix "-pkr-json" name) self'.packages;
      generateApp = name: pkg: let
        appName = "packer-" + lib.removeSuffix "-pkr-json" name;
      in
        lib.nameValuePair appName {
          inherit type;
          program = lib.getExe (pkgs.writeShellApplication {
            inherit runtimeInputs;
            name = appName;
            text =
              pre-text
              + ''
                packer init ${pkg}
                packer build ${pkg}
              '';
          });
        };
    in
      lib.mapAttrs' generateApp packerPackages;
  };
}
