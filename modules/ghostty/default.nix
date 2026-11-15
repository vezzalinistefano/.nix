{ pkgs, ... }:
{
  imports = [
    (import ../lib/mk-switchable-app.nix (import ./app.nix)).home
  ];

  programs = {
    ghostty = {
      enable = true;
      # macOS: installed by the switchable app (nix: ghostty-bin, homebrew: cask), not by home-manager.
      # Linux: the nixpkgs source build
      package = if pkgs.stdenv.hostPlatform.isDarwin then null else pkgs.ghostty;
      enableZshIntegration = true;
      settings = {
        # Left Option acts as Alt (tmux M-h/j/k/l); right Option still types è/à
        macos-option-as-alt = "left";
      };
    };
  };
}
