{ config, pkgs, inputs, ... }:

{
  imports = [ inputs.stylix.homeManagerModules.stylix ];
  stylix.enable = true;
  stylix.polarity = "dark";
  stylix.targets.gtk.enable = true;

  stylix.base16Scheme =
    "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";

  stylix.image = ./backgrounds/wallhaven-p96odm.png;

  stylix.cursor.package = pkgs.bibata-cursors;
  stylix.cursor.name = "Bibata-Modern-Ice";
  stylix.cursor.size = 20;

  stylix.fonts = {
    monospace = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font";
    };
    sansSerif = {
      package = pkgs.ibm-plex;
      name = "IBM Plex Sans Arabic";
    };
    serif = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Serif";
    };
    sizes = {
      terminal = 10;
      applications = 9;
    };
  };

  stylix.opacity.terminal = 0.92;

  stylix.targets.nixvim.enable = false;

  gtk.enable = true;
  gtk.iconTheme.package = pkgs.papirus-icon-theme;
  gtk.iconTheme.name = "Papirus";
}
