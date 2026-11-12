# Nix-Darwin Personal Configuration

**ABOUTME:** Comprehensive nix-darwin configuration for macOS with home-manager integration, nixvim, and development environments.

This is Stefano Vezzalini's personal nix-darwin configuration managing macOS system settings, user environments, and development tools through Nix flakes.

## Architecture Overview

### Core Components
- **nix-darwin**: macOS system configuration management
- **home-manager**: User environment and dotfiles management  
- **nixvim**: Neovim configuration through Nix
- **stylix**: System-wide theming and aesthetics
- **flakes**: Modular development environments

### Directory Structure
```
├── flake.nix                    # Main flake configuration
├── hosts/common/                # System configuration shared by all hosts
├── hosts/<HOSTNAME>/            # Per-host overrides (hostName); one dir per machine
├── home/common/                 # User home-manager configuration shared by all hosts
├── docs/wiki/                   # Wiki pages (e.g. new-host setup guide)
├── modules/                     # Reusable configuration modules
│   ├── nixvim/                  # Neovim configuration
│   ├── zsh/                     # Shell configuration
│   ├── tmux/                    # Terminal multiplexer
│   ├── vscode/                  # VSCode configuration
│   ├── ghostty/                 # Terminal emulator
│   ├── yabai/                   # Window manager
│   └── [other tools]
├── dev-shells/                  # Development environment flakes
├── flakes/                      # Standalone tool flakes
└── scripts/                     # Utility scripts
```

## Configuration Management

### Flake Inputs
- `nixpkgs`: Main package repository (unstable channel)
- `darwin`: nix-darwin for macOS system management
- `home-manager`: User environment management
- `nixvim`: Neovim configuration framework
- `stylix`: System theming

### System Configuration (`hosts/common/default.nix`)
- Hosts: SWS000154, SWS000135 (built via `mkDarwinHost` in `flake.nix`)
- TouchID sudo authentication
- Automatic garbage collection and store optimization
- Yabai window manager
- System packages: neovim, git
- Environment variables: EDITOR, GOPATH, NIXPATH

### User Environment (`home/common/default.nix`)
Core packages installed:
- **Development:** go, python3, nodejs tools, kubernetes tools
- **Cloud/DevOps:** google-cloud-sdk, kubectl, helm, terraform (tenv), ansible
- **Security:** sops, age, gpg
- **Productivity:** slack, spotify, raycast, obsidian
- **Terminal:** claude-code, ast-grep, fzf, lazygit, ripgrep

## Module System

### Nixvim Configuration (`modules/nixvim/`)
- Modular plugin system in `plugins/`
- Custom keymaps, options, and autocommands
- LSP integration with language servers
- Git integration (fugitive, gitsigns)
- Telescope fuzzy finder
- Harpoon navigation
- Tree-sitter syntax highlighting
- Gruvbox colorscheme with transparency

### Shell Configuration (`modules/zsh/`)
- Starship prompt
- Comprehensive git aliases
- Kubernetes shortcuts
- Custom functions for git worktree management
- Auto-completion and syntax highlighting

### Development Tools
- **Ghostty**: Modern terminal emulator with zsh integration
- **Tmux**: Terminal multiplexer with touch ID support
- **VSCode**: Basic configuration
- **Direnv**: Automatic environment loading

## Development Environments

### Available Flakes
- **Python 3.12** (`flakes/python/312/`): Virtual environment with black formatter
- **Terraform** (`dev-shells/terraform/`): Specific version with custom download
- **Docker** (`flakes/docker/`): Container development
- **Elasticsearch 9.1.0** (`dev-shells/elasticsearch/9.1.0/`): Search development

### Usage Pattern
```bash
# Enter development environment
nix develop path/to/flake

# Or using direnv
echo "use flake" > .envrc && direnv allow
```

## Styling and Theming

### Stylix Configuration (`modules/stylix/default.nix`)
- Base16 Kanagawa Dragon color scheme
- Dark mode preference
- Font stack:
  - Monospace: JetBrainsMono Nerd Font
  - Sans-serif: IBM Plex Sans Arabic
  - Serif: DejaVu Serif
- Terminal opacity: 90%
- Nixvim theming disabled (uses custom gruvbox)

## Maintenance and Operations

### Build Commands
```bash
# Apply darwin configuration
darwin-rebuild switch --flake /private/etc/nix-darwin
# (the flake attribute is picked from the machine hostname; or pass .#<HOSTNAME>)

# home-manager runs as a nix-darwin module, so there is no separate home-manager switch;
# the same command applies both. Build without applying:
darwin-rebuild build --flake /private/etc/nix-darwin
```

### Git Workflow Support
- **git-cleanup-orphaned.sh**: Automated cleanup of orphaned git worktrees and branches
- Protected branches: main, master, develop, dev
- Supports dry-run and automatic modes
- Integrated into zsh as `git-cleanup-orphaned` function

### Package Management
- Automatic garbage collection weekly
- Store optimization enabled
- Trusted user configuration for multi-user builds

## Security Features
- TouchID integration for sudo
- GPG module for signing and encryption
- SOPS/age for secrets management
- No hardcoded secrets in configuration

## Development Workflow

### Key Tools Integration
- **ast-grep**: AST-based code search (aliased as `sg`)
- **Pre-commit**: Git hooks for code quality
- **Nixfmt**: Nix code formatting
- **Claude-code**: AI-powered development assistant
- **Lazygit**: Terminal git UI

### Language Support
- **Go**: Full toolchain with golangci-lint, gotest
- **Python**: UV, poetry, multiple versions support
- **Kubernetes**: kubectl, helm, argocd CLI
- **Cloud**: GCP SDK with auth plugins
- **Infrastructure**: Terraform/Terragrunt via tenv

## Configuration Principles
- **Modular Design**: Each tool in separate module
- **Declarative**: All configuration in version control
- **Reproducible**: Flake.lock pins all dependencies
- **User-Centric**: Home-manager for user-space configuration
- **Development-Focused**: Rich tooling for software engineering

## Switchable apps (nix or Homebrew)
GUI apps with a nixpkgs package and a Homebrew cask (spotify, brave, dbeaver, raycast, slack, telegram-desktop, thunderbird, utm) can be installed from either. Each folder holds `app.nix` (name, package, cask, default), `default.nix` (home-manager half) and `darwin.nix` (adds the cask), all built by `modules/lib/mk-switchable-app.nix`. Switch per host in `hosts/<HOSTNAME>/default.nix`:
```nix
apps.spotify.source = "nix";   # or "homebrew"
```
Defaults live in each `app.nix` (spotify is "homebrew", the rest "nix"). To add an app: copy an existing folder and import its `darwin.nix` in `hosts/common/default.nix` and its `default.nix` in `home/common/default.nix`.

## Adding a Host
See `docs/wiki/new-host-setup.md` (and `docs/wiki/managing-apps.md` for installing and updating apps). In short: create `hosts/<HOSTNAME>/default.nix` (imports `../common`, sets `networking.hostName`) and add `"<HOSTNAME>" = mkDarwinHost { hostname = "<HOSTNAME>"; };` to `flake.nix`.

## Extension Points
- Add new modules in `modules/` directory
- Create development flakes in `dev-shells/` or `flakes/`
- Extend zsh configuration with custom functions
- Add nixvim plugins in `modules/nixvim/plugins/`

This configuration provides a complete, reproducible macOS development environment suitable for cloud-native development, DevOps, and general software engineering tasks.