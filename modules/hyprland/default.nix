{ pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    # Hyprland and its portal are installed by NixOS (programs.hyprland in the host config)
    package = null;
    portalPackage = null;
    # Hyprland 0.57 reads hyprland.lua; stylix adds the colours through `settings`
    configType = "lua";
    extraConfig = builtins.readFile ./hyprland.lua;
  };

  # Tools the key bindings call
  home.packages = with pkgs; [
    brightnessctl
    grim
    libnotify
    playerctl
    slurp
    wl-clipboard
  ];
}
