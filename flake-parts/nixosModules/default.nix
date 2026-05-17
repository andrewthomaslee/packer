{inputs, ...}: {
  flake.nixosModules.default = {
    modulesPath,
    pkgs,
    lib,
    ...
  }: {
    imports = [
      (modulesPath + "/profiles/minimal.nix")
      (modulesPath + "/profiles/perlless.nix")
      inputs.determinate.nixosModules.default
    ];

    boot = {
      kernelPackages = pkgs.linuxPackages_hardened;
      kernel.sysctl = {
        "kernel.kptr_restrict" = 2; # Hide kernel pointers
        "kernel.dmesg_restrict" = 1; # Restrict dmesg access
      };
    };

    system.stateVersion = lib.trivial.release;

    # --- OpenSSH --- #
    services.openssh = {
      enable = lib.mkForce true;
      openFirewall = true;
      ports = [22];
      authorizedKeysFiles = ["/etc/ssh/global_keys"];
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "prohibit-password";
        X11Forwarding = false;
        AllowTcpForwarding = "no";
      };
    };

    # --- Clan-Core --- #
    clan.core.settings.state-version.enable = lib.mkForce false;

    # --- Nixpkgs --- #
    nixpkgs.config.allowUnfree = true;

    # --- Nix --- #
    nix.settings = {
      auto-optimise-store = true;
      trusted-users = ["root"];
      allowed-users = ["root"];
    };

    # Often hangs
    systemd = {
      tmpfiles.rules = [
        "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
      ];
      services = {
        NetworkManager-wait-online.enable = false;
        systemd-networkd-wait-online.enable = false;
        xserver.enable = false;
      };
    };
    # --- Localization --- #
    i18n.defaultLocale = "en_US.UTF-8";
    time.timeZone = "America/Chicago";

    # --- Services --- #
    services.journald.extraConfig = lib.mkDefault "SystemMaxUse=1G";

    # --- Hardware --- #
    hardware.enableRedistributableFirmware = true;

    # --- Environment --- #
    environment = {
      etc."ssh/global_keys".text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOb4q9LWJR54SzRkfmsA5KWA5/SDEG853oFC8TVilCW/"; # TODO: Change to your public key
      enableAllTerminfo = true;
      localBinInPath = true;
      systemPackages = with pkgs; [
        fh
        tailscale
        rsync
      ];
    };

    # --- Cloud-Init --- #
    services.cloud-init = {
      enable = true;
      network.enable = true;
    };

    # --- Networking --- #
    networking = {
      firewall.allowPing = true;
      useNetworkd = true;
      networkmanager.enable = false;
      useDHCP = false;
    };

    security.sudo.enable = false;
  };
}
