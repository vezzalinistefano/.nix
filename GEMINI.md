---
title: nix-configuration-repo
description: Configure my system(s) using the nix language
---

# Nix
This folder holds the configuration files in the nix language.
Used to configure all my system and users across MacOS (using darwin) and
linux (mostly NixOS)

## Core principles
- **Flakes only**: All configurations are managed through Nix Flakes.
- **Home manager**: User-specific configurations are managed via a standalone `home-manager` module.
- **Modular and composable**: The configuration is broken down into small, reusable modules for better organization and maintainability.

## Folder structure

- **`/dev-shells`**: Contains standalone flakes for creating specific development shells (e.g., `elasticsearch`, `terraform`).
- **`/flake.nix`**: The main entrypoint for the flake. It defines the project's dependencies (inputs) and the final system configurations (outputs).
- **`/flakes`**: Holds flakes for setting up quick, ad-hoc environments, like for `docker` or `python`.
- **`/home`**: Contains `home-manager` configurations, which manage user-level packages and dotfiles for specific users and hosts.
- **`/hosts`**: Defines the system-level configuration for each specific machine (e.g., `iungo-macbook`). This is where `nix-darwin` modules are imported.
- **`/modules`**: A collection of reusable modules for configuring various applications and tools like `nixvim`, `zsh`, `vscode`, and more.
- **`/scripts`**: A place for utility shell scripts.

## Working commands

Apply the latest configurations on a macOS system:
```bash
sudo darwin-rebuild switch --flake .#SWS000154
```

Check the home-manager configuration without applying it:
```bash
home-manager build --flake .#stefanovezzalini
```

## Home manager
- Installing packages via `home-manager` is preferred when possible as it keeps the system environment cleaner.
- Documentation for `home-manager` options and packages can be found by running `man home-manager-options`.
- Programs installed using `home-manager` should have their configuration in their own file inside `modules/`.

## Best practices
- `snake_case` for file names and nix options.
- 2-space indentation.
- Prefer nested attribute sets for readability, for example:
  ```nix
  # Good
  programs.git = {
    enable = true;
    userName = "Stefano Vezzalini";
  };

  # Bad
  programs.git.enable = true;
  programs.git.userName = "Stefano Vezzalini";
  ```