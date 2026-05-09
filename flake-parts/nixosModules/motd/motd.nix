{...}: {
  # ------ NixOS Modules ------ #
  flake.nixosModules.default = {
    pkgs,
    config,
    ...
  }: {
    programs.bash.interactiveShellInit = let
      runtimeInputs = with pkgs; [
        coreutils
        gawk
        procps
        busybox
      ];
      sshMotd = pkgs.writeShellApplication {
        name = "sshMotd";
        inherit runtimeInputs;
        text = builtins.readFile ./sshMotd.sh;
      };
      localMotd = pkgs.writeShellApplication {
        name = "localMotd";
        inherit runtimeInputs;
        text = builtins.readFile ./localMotd.sh;
      };
    in ''
      if [ -n "$SSH_CONNECTION" ] && [ -z "$MOTD_DISPLAYED" ]; then
        export MOTD_DISPLAYED=1
        ${sshMotd}/bin/sshMotd
      elif [ -z "$SSH_CONNECTION" ] && [ -z "$MOTD_DISPLAYED" ]; then
        export MOTD_DISPLAYED=1
        ${localMotd}/bin/localMotd
      fi
    '';
  };
}
