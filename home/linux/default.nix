# Linux desktop user configuration (on top of ../common): Hyprland and the few
# pieces around it, plus the GUI apps the Macs get through the switchable apps.
{ pkgs, ... }:
{
  imports = [
    ../../modules/claude-code
    ../../modules/direnv
    ../../modules/feather
    ../../modules/gpg-agent
    ../../modules/hyprland
    ../../modules/hyprpolkitagent
    ../../modules/hyprlock
    ../../modules/librewolf
    ../../modules/mako
    ../../modules/opencode
    ../../modules/vicinae
    ../../modules/vscodium
    ../../modules/waybar
  ];

  home.packages = with pkgs; [
    btop
    pavucontrol
    telegram-desktop
  ];

  home.stateVersion = "26.05";
}
