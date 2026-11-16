{
  inputs,
  ...
}:

# Shared by every host, macOS and NixOS. Platform and work-only parts live in
# ../darwin, ../linux and ../work; flake.nix picks the set for each host.
{
  nixpkgs.config.allowUnfree = true;
  imports = [
    inputs.nixvim.homeModules.nixvim
    ../../modules/age
    ../../modules/alacritty
    ../../modules/ansible
    ../../modules/ast-grep
    ../../modules/bitwarden-cli
    ../../modules/bun
    # ../../modules/checkov  # Disabled: causes OOM during build (pulls in heavy data science deps)
    # ../../modules/claude-code
    # ../../modules/direnv
    ../../modules/fd
    ../../modules/fira-code-nerd-font
    ../../modules/fzf
    ../../modules/ghostty
    ../../modules/git
    ../../modules/go
    ../../modules/golangci-lint
    ../../modules/gotest
    ../../modules/gotools
    ../../modules/gpg
    ../../modules/hack-nerd-font
    ../../modules/herdr
    ../../modules/hugo
    ../../modules/jq
    ../../modules/jsonnet
    ../../modules/lazygit
    ../../modules/llama-cpp
    ../../modules/mdformat
    ../../modules/nixfmt
    ../../modules/nixvim
    ../../modules/nmap
    ../../modules/obsidian
    # ../../modules/opencode # nixpkgs opencode 2.2.5 node_modules fails to build; installed via Homebrew
    ../../modules/poetry
    ../../modules/poppler
    ../../modules/pre-commit
    ../../modules/python3
    ../../modules/ripgrep
    ../../modules/sops
    ../../modules/stylix
    ../../modules/swaks
    ../../modules/tmux
    ../../modules/tree
    ../../modules/trivy
    ../../modules/uv
    ../../modules/watch
    ../../modules/yamllint
    ../../modules/yq
    ../../modules/zsh
  ];

  home = {
    # username and homeDirectory come from the host's users.users.<name>;
    # stateVersion is set per platform (home/darwin, home/linux)
    sessionPath = [ "$HOME/.local/bin" ];
  };

  programs.home-manager.enable = true;
}
