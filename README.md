# Clan Template

<h3 align="center">
  <strong><u>Clan Template</u></strong>
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
│   ├───aarch64-linux
│   │   ├───packer-aws-aarch64: app: no description
│   │   ├───packer-aws-x86_64: app: no description
│   │   ├───packer-hcloud-aarch64: app: no description
│   │   ├───packer-hcloud-x86_64: app: no description
│   │   ├───update-flake-show: app: no description
│   │   └───watch-documentation: app: Run mkdocs in watch mode over your documentation folder. Automatically rebuilds your docs on changes.
│   └───x86_64-linux
│       ├───packer-aws-aarch64: app: no description
│       ├───packer-aws-x86_64: app: no description
│       ├───packer-hcloud-aarch64: app: no description
│       ├───packer-hcloud-x86_64: app: no description
│       ├───update-flake-show: app: no description
│       └───watch-documentation: app: Run mkdocs in watch mode over your documentation folder. Automatically rebuilds your docs on changes.
├───clan: unknown
├───clanInternals: unknown
├───darwinConfigurations: unknown
├───darwinModules: unknown
├───devShells
│   ├───aarch64-linux
│   │   └───default omitted (use '--all-systems' to show)
│   └───x86_64-linux
│       └───default: development environment 'nix-shell'
├───formatter
│   ├───aarch64-linux omitted (use '--all-systems' to show)
│   └───x86_64-linux: package 'alejandra-4.0.0'
├───nixosConfigurations
│   ├───aws-aarch64: NixOS configuration
│   ├───aws-x86_64: NixOS configuration
│   ├───hcloud-aarch64: NixOS configuration
│   └───hcloud-x86_64: NixOS configuration
├───nixosModules
│   ├───aws: NixOS module
│   ├───clan-machine-aws-aarch64: NixOS module
│   ├───clan-machine-aws-x86_64: NixOS module
│   ├───clan-machine-hcloud-aarch64: NixOS module
│   ├───clan-machine-hcloud-x86_64: NixOS module
│   ├───default: NixOS module
│   └───hcloud: NixOS module
└───packages
    ├───aarch64-linux
    │   ├───aws-aarch64-pkr-json omitted (use '--all-systems' to show)
    │   ├───aws-x86_64-pkr-json omitted (use '--all-systems' to show)
    │   ├───devShell omitted (use '--all-systems' to show)
    │   ├───documentation omitted (use '--all-systems' to show)
    │   ├───hcloud-aarch64-pkr-json omitted (use '--all-systems' to show)
    │   └───hcloud-x86_64-pkr-json omitted (use '--all-systems' to show)
    └───x86_64-linux
        ├───aws-aarch64-pkr-json: package 'aws-aarch64.pkr.json'
        ├───aws-x86_64-pkr-json: package 'aws-x86_64.pkr.json'
        ├───devShell: package 'nix-shell'
        ├───documentation: package 'mkdocs-flake-documentation'
        ├───hcloud-aarch64-pkr-json: package 'hcloud-aarch64.pkr.json'
        └───hcloud-x86_64-pkr-json: package 'hcloud-x86_64.pkr.json'
```