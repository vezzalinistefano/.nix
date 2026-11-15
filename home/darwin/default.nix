# macOS-only user configuration (on top of ../common).
{ pkgs, ... }:
{
  imports = [
    ../../modules/brave
    ../../modules/dbeaver
    ../../modules/gemini-cli
    ../../modules/linearmouse
    ../../modules/pam-reattach
    ../../modules/raycast
    ../../modules/spotify
    ../../modules/telegram-desktop
    ../../modules/terminal-notifier
    ../../modules/thunderbird
    ../../modules/utm
    ../../modules/vscode
  ];

  # Deploys the NixOS hosts from the Mac (`nrs <host>` in modules/zsh)
  home.packages = [ pkgs.nixos-rebuild ];

  home.stateVersion = "25.05";
}
