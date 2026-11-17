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
      # 14" 1080p laptop screen at scale 1 needs a larger UI font than the Mac
      applications = if pkgs.stdenv.hostPlatform.isDarwin then 9 else 11;
    };
  };

  stylix.opacity.terminal = 0.90;

  stylix.targets.nixvim.enable = false;
  stylix.targets.obsidian.enable = false;
  # GTK and Qt apps (volume control, file dialogs, passphrase and admin prompts) follow the
  # theme on Linux. GTK has no effect on macOS, and stylix's gtk4 theme clashes there with
  # home-manager's gtk.gtk4.theme.
  stylix.targets.gtk.enable = pkgs.stdenv.hostPlatform.isLinux;
  stylix.targets.qt.enable = pkgs.stdenv.hostPlatform.isLinux;
  # Not using a KDE or GNOME desktop
  stylix.targets.kde.enable = false;
  stylix.targets.gnome.enable = false;
  # rofi is not used (vicinae is the launcher); its stylix module also sets a renamed option
  stylix.targets.rofi.enable = false;
}
