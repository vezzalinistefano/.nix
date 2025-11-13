# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a nix-darwin configuration repository that manages a complete macOS development environment using Nix flakes. The configuration is split between system-level (darwin) and user-level (home-manager) settings, with a modular architecture for different applications and services.

## Architecture

- **Flake-based Configuration**: Main `flake.nix` defines inputs (nixpkgs, nix-darwin, home-manager, nixvim, stylix) and outputs for darwinConfigurations
- **Host Configuration**: `hosts/iungo-macbook/` contains system-level settings (hostname: SWS000154)
- **User Configuration**: `home/iungo-macbook/` manages user packages and imports all application modules
- **Modular Structure**: `modules/` directory contains individual application configurations:
  - `nixvim/` - Complete Neovim setup with plugins, keymaps, options, autocommands, filetypes
  - `zsh/` - Shell configuration with extensive git aliases and kubectl integration
  - `tmux/`, `vscode/`, `obsidian/`, `yabai/`, `ghostty/` - Individual application configs
- **Development Shells**: `dev-shells/` and `flakes/` contain isolated environments for specific development tools

## Common Commands

### System Management
```bash
# Apply system configuration changes (requires sudo)
sudo darwin-rebuild switch --flake /private/etc/nix-darwin

# Check flake syntax and evaluate configuration
nix flake check

# Format all nix files
nixfmt **/*.nix
```

### Development Environments
```bash
# Enter terraform development shell
nix develop ./dev-shells/terraform

# Enter python development shell  
nix develop ./flakes/python/312

# Enter elasticsearch development shell
nix develop ./dev-shells/elasticsearch/9.1.0
```

### Package Management
```bash
# Search for packages
nix search nixpkgs <package-name>

# Add new packages to home/iungo-macbook/default.nix in the packages list

# Garbage collection (automatic weekly, or manual)
nix-collect-garbage --delete-older-than 1w
nix-store --optimise
```

## Configuration Structure

- **System packages** go in `hosts/iungo-macbook/default.nix` 
- **User packages** go in `home/iungo-macbook/default.nix`
- **Application-specific config** should be added as new modules in `modules/` directory
- **Development environments** go in `dev-shells/` or `flakes/` directories

## Key Environment Variables

- `EDITOR=nvim` 
- `GOPATH=/Users/stefanovezzalini/go`
- `NIXPATH=/etc/nix-darwin`

## Special Features

- TouchID authentication enabled for sudo
- Automatic nix store optimization and garbage collection
- Yabai window manager service enabled
- Extensive git aliases configured in zsh module
- ast-grep available as `sg` command for code search