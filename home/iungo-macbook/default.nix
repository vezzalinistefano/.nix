{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
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
      lazygit
      pre-commit
      argocd
      fzf

      nixfmt-rfc-style
      ripgrep
      raycast
      tree
    ];
  };

  programs.home-manager.enable = true;
}
