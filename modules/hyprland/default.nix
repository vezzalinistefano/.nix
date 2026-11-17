{
  pkgs,
  config,
  lib,
  ...
}:
let
  cursor = config.stylix.cursor;
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    # Hyprland and its portal are installed by NixOS (programs.hyprland in the host config)
    package = null;
    portalPackage = null;
    # Hyprland 0.57 reads hyprland.lua; stylix adds the colours through `settings`
    configType = "lua";
    extraConfig = ''
      -- Pointer theme from stylix.cursor. Hyprland only takes it from its own environment:
      -- greetd starts it without home-manager's session variables, and its gsettings
      -- fallback finds no gsettings binary. Without this it keeps its default cursor.
    ''
    + lib.optionalString (cursor != null) ''
      hl.env("HYPRCURSOR_THEME", ${lib.strings.escapeNixString cursor.name})
      hl.env("HYPRCURSOR_SIZE", "${toString cursor.size}")
      hl.env("XCURSOR_THEME", ${lib.strings.escapeNixString cursor.name})
      hl.env("XCURSOR_SIZE", "${toString cursor.size}")
    ''
    + builtins.readFile ./hyprland.lua;
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
