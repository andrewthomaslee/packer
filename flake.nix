{
  description = "Minimal NixOS Packer Images and Scripts";
  inputs = {
    # Nixpkgs
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2511";

    # Determinate Nix
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    # Clan.lol
    clan-core = {
      url = "https://git.clan.lol/clan/clan-core/archive/25.11.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Mkdocs
    mkdocs-flake = {
      url = "github:applicative-systems/mkdocs-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Utility Flakes
    flake-parts.follows = "clan-core/flake-parts";
    import-tree.url = "github:vic/import-tree";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = [
        (inputs.import-tree ./flake-parts)
        inputs.mkdocs-flake.flakeModules.default
        inputs.clan-core.flakeModules.default
      ];
    };
}
