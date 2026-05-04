{
  inputs,
  pkgs,
  ...
}:

{
  nixpkgs.config.allowUnfree = true;
  imports = [
    inputs.nixvim.homeModules.nixvim
    ../../modules/age
    ../../modules/alacritty
    ../../modules/ansible
    ../../modules/argocd
    ../../modules/ast-grep
    ../../modules/brave
    # ../../modules/checkov  # Disabled: causes OOM during build (pulls in heavy data science deps)
    # ../../modules/claude-code
    ../../modules/dbeaver
    # ../../modules/direnv
    ../../modules/fd
    ../../modules/fira-code-nerd-font
    ../../modules/fzf
    ../../modules/gemini-cli
    ../../modules/git
    ../../modules/glab
    ../../modules/go
    ../../modules/golangci-lint
    ../../modules/google-cloud-sdk
    ../../modules/gotest
    ../../modules/gotools
    ../../modules/gpg
    ../../modules/hack-nerd-font
    ../../modules/hugo
    ../../modules/jq
    ../../modules/jsonnet
    ../../modules/k9s
    ../../modules/kubecolor
    ../../modules/kubectl
    ../../modules/kubernetes-helm
    ../../modules/kustomize
    ../../modules/lazygit
    ../../modules/llama-cpp
    ../../modules/mdformat
    ../../modules/nixfmt
    ../../modules/nixvim
    ../../modules/obsidian
    ../../modules/pam-reattach
    ../../modules/poetry
    ../../modules/pre-commit
    ../../modules/python3
    ../../modules/raycast
    ../../modules/ripgrep
    ../../modules/slack
    ../../modules/sops
    ../../modules/spotify
    ../../modules/stylix
    ../../modules/swaks
    ../../modules/tenv
    ../../modules/terraform-docs
    ../../modules/tfupdate
    ../../modules/tflint
    ../../modules/thunderbird
    ../../modules/tmux
    ../../modules/tree
    ../../modules/trivy
    ../../modules/utm
    ../../modules/uv
    ../../modules/vscode
    ../../modules/watch
    ../../modules/yamllint
    ../../modules/yq
    ../../modules/zsh
  ];

  home = {
    username = "stefanovezzalini";
    homeDirectory = "/Users/stefanovezzalini";
    stateVersion = "25.05";
    sessionPath = [ "$HOME/.local/bin" ];
  };

  programs.home-manager.enable = true;
}
