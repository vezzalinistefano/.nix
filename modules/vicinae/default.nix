_: {
  # Raycast-style launcher for Linux: apps, clipboard history, calculator, emoji,
  # window switching and extensions. Themed by stylix. Keys are in modules/hyprland:
  # Super+Space opens it, Super+Shift+V jumps to the clipboard history.
  programs.vicinae = {
    enable = true;
    systemd = {
      enable = true;
      autoStart = true;
    };
  };
}
