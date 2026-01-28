{
  inputs,
  pkgs,
  ...
}:

{
  nixpkgs.config.allowUnfree = true;
  imports = [
    inputs.nixvim.homeModules.nixvim
    ../../modules/nixvim
    ./rice.nix
    ./git.nix
    ./alacritty.nix
    ../../modules/vscode
    ../../modules/zsh
    ../../modules/tmux
    ../../modules/obsidian
    ../../modules/direnv
    ../../modules/gpg
    ../../modules/kube
  ];

  home = {
    username = "stefanovezzalini";
    homeDirectory = "/Users/stefanovezzalini";
    stateVersion = "25.05";

    packages = with pkgs; [
      pam-reattach # Reattach to the user's GUI session on macOS during authentication (for Touch ID support in tmux)
      slack
      spotify
      (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
      go
      gotools
      gotest
      golangci-lint
      kubectl
      kubernetes-helm
      jsonnet
      swaks
      python3
      uv
      poetry
      ansible
      utm
      sops
      age
      yq
      jq
      tenv
      tflint
      checkov
      trivy
      terraform-docs
      tfupdate
      lazygit
      pre-commit
      argocd
      fzf
      python313Packages.mdformat
      hugo
      claude-code
      ast-grep
      dbeaver-bin
      brave
      llama-cpp

      nixfmt-rfc-style
      ripgrep
      raycast
      tree

      nerd-fonts.fira-code
      nerd-fonts.hack
    ];
  };

  programs.home-manager.enable = true;
}
