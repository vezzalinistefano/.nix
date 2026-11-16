{ pkgs, inputs, ... }:

{
  imports = [ inputs.stylix.homeModules.stylix ];
  stylix.enable = true;
  stylix.polarity = "dark";

  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/pop.yaml";

  stylix.fonts = {
    monospace = {
      name = "Hack Nerd Font";
    };
    sansSerif = {
      package = pkgs.ibm-plex;
      name = "IBM Plex Sans Arabic";
    };
    serif = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Serif";
    };

    emoji =
      if pkgs.stdenv.hostPlatform.isDarwin then
        { name = "Apple Color Emoji"; }
      else
        {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
    sizes = {
      terminal = 12;
      applications = 9;
    };
  };

  stylix.opacity.terminal = 0.90;

  stylix.targets.nixvim.enable = false;
  stylix.targets.obsidian.enable = false;
  # GTK has no effect on macOS, and stylix's gtk4 theme clashes with home-manager's gtk.gtk4.theme.
  # Kept off on Linux too for now: GTK apps there are untested with it.
  stylix.targets.gtk.enable = false;
  # Not using a Qt, KDE or GNOME desktop: skip the theme engines stylix would install on Linux
  stylix.targets.qt.enable = false;
  stylix.targets.kde.enable = false;
  stylix.targets.gnome.enable = false;
  # rofi is not used (vicinae is the launcher); its stylix module also sets a renamed option
  stylix.targets.rofi.enable = false;
}
