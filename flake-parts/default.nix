{
  inputs,
  self,
  lib,
  ...
}: let
  # Define custom lib accessable as `customLib.custom`
  customLib = lib.extend (self: super: {custom = import ../lib {inherit lib;};});
  inherit (customLib.custom) relativeToRoot;
in {
  # ------ Per-System ------ #
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    _module.args = {
      inherit customLib;
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    };

    # Formatter
    formatter = pkgs.alejandra;
    # Mkdocs
    documentation.mkdocs-root = relativeToRoot "documentation";
  };

  flake = {
    # ------ NixOS Modules ------ #
    nixosModules.default._module.args = {inherit customLib;}; # pass `customLib` to all nixosModules

    # --- Clan Configuration ------ #
    clan = {
      inventory = import (relativeToRoot "inventory.nix") {inherit self inputs customLib;};
      specialArgs = {inherit customLib inputs self;};
    };
  };
}
