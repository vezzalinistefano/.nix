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
├── hosts/iungo-macbook/         # Host-specific system configuration
├── home/iungo-macbook/          # User home-manager configuration
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

### System Configuration (`hosts/iungo-macbook/default.nix`)
- Hostname: SWS000154
- TouchID sudo authentication
- Automatic garbage collection and store optimization
- Yabai window manager
- System packages: neovim, git
- Environment variables: EDITOR, GOPATH, NIXPATH

### User Environment (`home/iungo-macbook/default.nix`)
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

### Stylix Configuration (`home/iungo-macbook/rice.nix`)
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

# Apply home-manager configuration  
home-manager switch --flake /private/etc/nix-darwin
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

## Extension Points
- Add new modules in `modules/` directory
- Create development flakes in `dev-shells/` or `flakes/`
- Extend zsh configuration with custom functions
- Add nixvim plugins in `modules/nixvim/plugins/`

This configuration provides a complete, reproducible macOS development environment suitable for cloud-native development, DevOps, and general software engineering tasks.