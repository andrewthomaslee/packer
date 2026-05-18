{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.default = {
    modulesPath,
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = [
      (modulesPath + "/profiles/minimal.nix")
      inputs.determinate.nixosModules.default
    ];

    security.sudo.enable = false;

    # --- Boot --- #
    boot = {
      kernelPackages = pkgs.linuxPackages;
      kernel.sysctl = {
        "kernel.kptr_restrict" = 2; # Hide kernel pointers
        "kernel.dmesg_restrict" = 1; # Restrict dmesg access
      };
      tmp = {
        useTmpfs = false;
        cleanOnBoot = true;
      };
      loader.grub = {
        enable = true;
        efiInstallAsRemovable = true;
        efiSupport = true;
      };
    };

    system.stateVersion = lib.trivial.release;

    # --- Services --- #
    services = {
      # --- OpenSSH --- #
      openssh = {
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
      journald.extraConfig = lib.mkDefault "SystemMaxUse=1G";
      # --- Cloud-Init --- #
      cloud-init = {
        enable = true;
        network.enable = true;
      };
      # --- Tailscale --- #
      tailscale.enable = true;
      networkd-dispatcher = {
        enable = true;
        rules."50-tailscale" = {
          onState = ["routable"];
          script = ''
            #!${pkgs.runtimeShell}
            NETDEV=$(${pkgs.iproute2}/bin/ip -o route get 8.8.8.8 | cut -f 5 -d " ")
            ${pkgs.ethtool}/bin/ethtool -K "$NETDEV" rx-udp-gro-forwarding on rx-gro-list off
          '';
        };
      };
    };

    # --- Clan-Core --- #
    clan.core.settings.state-version.enable = lib.mkForce false;

    # --- Nixpkgs --- #
    nixpkgs = {
      config.allowUnfree = true;
      overlays = [self.overlays.default];
    };

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

    # --- Hardware --- #
    hardware.enableRedistributableFirmware = true;

    # --- Environment --- #
    environment = {
      etc."ssh/global_keys".text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOb4q9LWJR54SzRkfmsA5KWA5/SDEG853oFC8TVilCW/"; # TODO: Change to your public key
      enableAllTerminfo = true;
      localBinInPath = true;
      systemPackages = with pkgs; [
        fh
        rsync
      ];
    };

    # --- Networking --- #
    networking = {
      hostName = lib.mkForce config.clan.core.settings.machine.name;
      useNetworkd = true;
      useDHCP = false;
      networkmanager.enable = false;
      firewall = {
        enable = true;
        allowPing = true;
        trustedInterfaces = ["tailscale0"];
        checkReversePath = "loose";
      };
    };
  };
}
