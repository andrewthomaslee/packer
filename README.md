# Clan Template

<h3 align="center">
  <strong><u>Clan Template</u></strong>
</h3>

<h3 align="center">
  <strong><u>PLEASE UPDATE YOUR INFO WHERE `TODO` IN REPO</u></strong>
</h3>


## Project layout

    flake.nix       # Flake that controls the project
    flake.lock      # Flake's lock file
    inventory.nix   # Clan.lol Inventory of all NixOS machines and Services
    .envrc          # direnv configuration
    .env.schema     # Varlock schema

    machines/       # NixOS Machines   
    lib/            # Custom functions accessible via `lib.custom`

    flake-parts/        # Top-level Flake Part files
        default.nix     # Default flake-parts configuration
        devShells.nix   # Development Shells
        apps/           # Applications `nix run .#<app>`
        packages/       # Packages `nix build .#<package>`
        nixosModules/   # NixOS Modules

    documentation/      # MkDocs
        mkdocs.yml      # MkDocs configuration
        docs/           # Documentation source

    .github/workflows/      # GitHub Actions workflows
        ci.yml              # CI workflow for FlakeHub Cache and MkDocs

    sops/                   # Encrypted Secrets
    vars/                   # Clan.lol implementaion of SOPS

## Flake Outputs

```console
$ nix flake show
├───apps
├───clan: unknown
├───clanInternals: unknown
├───darwinConfigurations: unknown
├───darwinModules: unknown
├───devShells
├───formatter
├───homeConfigurations: unknown
├───homeModules: unknown
├───nixosConfigurations
├───nixosModules
├───overlays
├───packages
└───templates
```