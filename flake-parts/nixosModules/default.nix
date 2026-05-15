{inputs, ...}: {
  flake.nixosModules.default = {
    modulesPath,
    pkgs,
    lib,
    ...
  }: {
    imports = [
      (modulesPath + "/profiles/minimal.nix")
      inputs.determinate.nixosModules.default
    ];

    # --- Users --- #
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
      };
    };

    # Tailscale
    services.tailscale = {
      enable = lib.mkDefault true;
      port = lib.mkDefault 0;
      useRoutingFeatures = lib.mkDefault "server";
    };

    # --- Clan-Core --- #
    clan.core = {
      deployment.requireExplicitUpdate = lib.mkDefault false;
      settings.state-version.enable = lib.mkForce false;
    };

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
        NetworkManager-wait-online.enable = lib.mkForce false;
        systemd-networkd-wait-online.enable = lib.mkForce false;
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
      systemPackages = [inputs.fh.packages.${pkgs.stdenv.hostPlatform.system}.default];
    };

    # --- Cloud-Init --- #
    services.cloud-init = {
      enable = true;
      network.enable = true;
    };

    # --- Networking --- #
    networking = {
      firewall.allowPing = true;
      useNetworkd = lib.mkDefault true;
      networkmanager.enable = lib.mkDefault false;
      useDHCP = lib.mkDefault false;
    };
  };
}
