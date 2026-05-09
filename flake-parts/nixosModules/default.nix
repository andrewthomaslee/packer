{
  inputs,
  lib,
  ...
}: {
  flake = {
    # ------ NixOS Modules ------ #
    nixosModules.default = {
      pkgs,
      customLib,
      ...
    }: let
      inherit (customLib.custom) relativeToRoot;
    in {
      imports = [
        inputs.determinate.nixosModules.default
      ];

      # --- OpenSSH --- #
      services.openssh = {
        enable = true;
        openFirewall = true;
        ports = [22];
        authorizedKeysFiles = ["/etc/ssh/global_keys"];
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };

      # --- Clan-Core --- #
      clan.core = {
        deployment.requireExplicitUpdate = lib.mkDefault false;
        settings.state-version.enable = lib.mkDefault true;
      };

      # --- Nixpkgs --- #
      nixpkgs = {
        config.allowUnfree = lib.mkDefault true;
        hostPlatform = lib.mkDefault "x86_64-linux";
      };

      # --- Nix --- #
      nix.settings = {
        auto-optimise-store = lib.mkDefault true;
        trusted-users = ["root"];
        allowed-users = ["root"];
      };

      systemd.services = {
        NetworkManager-wait-online.enable = lib.mkForce false;
        systemd-networkd-wait-online.enable = lib.mkForce false;
      };

      # --- Localization --- #
      i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
      time.timeZone = lib.mkDefault "America/Chicago";

      # --- Services --- #
      services = {
        journald.extraConfig = lib.mkDefault "SystemMaxUse=1G";
        fwupd.enable = lib.mkDefault true;
        acpid.enable = lib.mkDefault true;
      };

      # --- Hardware --- #
      hardware.enableRedistributableFirmware = lib.mkDefault true;

      # --- Environment --- #
      environment = {
        etc = {
          "ssh/global_keys".text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOb4q9LWJR54SzRkfmsA5KWA5/SDEG853oFC8TVilCW/"; # TODO: Change to your public key
          "nixos/flake.nix" = {
            source = relativeToRoot "flake.nix";
            mode = "0644";
          };
          "nixos/flake.lock" = {
            source = relativeToRoot "flake.lock";
            mode = "0644";
          };
        };
        enableAllTerminfo = lib.mkDefault true;
        localBinInPath = lib.mkDefault true;
        systemPackages = [inputs.fh.packages.${pkgs.stdenv.hostPlatform.system}.default];
      };

      # --- Cloud-Init --- #
      services.cloud-init = {
        enable = lib.mkDefault true;
        network.enable = lib.mkDefault true;
      };

      # --- Networking --- #
      networking = {
        firewall = {
          enable = lib.mkForce false;
          allowPing = lib.mkForce true;
        };
        useNetworkd = lib.mkDefault true;
        networkmanager.enable = lib.mkDefault false;
        useDHCP = lib.mkForce false;
      };

      # --- Boot --- #
      boot = {
        tmp = {
          useTmpfs = lib.mkDefault false;
          cleanOnBoot = lib.mkDefault true;
        };
        loader.grub = {
          enable = lib.mkDefault true;
          efiSupport = lib.mkDefault true;
          efiInstallAsRemovable = lib.mkDefault true;
        };
      };

      # --- Disko Partitions --- #
      disko.devices = {
        disk = {
          main = {
            name = "main";
            device = lib.mkDefault "/dev/sda";
            type = "disk";
            content = {
              type = "gpt";
              partitions = {
                boot = {
                  size = "1M";
                  type = "EF02";
                  priority = 1;
                };
                ESP = {
                  type = "EF00";
                  size = "3G";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = ["umask=0077"];
                  };
                };
                nixos = {
                  size = "100%";
                  content = {
                    type = "filesystem";
                    format = "ext4";
                    mountpoint = "/";
                    mountOptions = ["noatime"];
                    extraArgs = ["-L" "nixos"];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
