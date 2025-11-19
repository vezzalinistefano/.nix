{ pkgs, inputs, ... }:

{
  imports = [ inputs.stylix.homeModules.stylix ];
  stylix.enable = true;
  stylix.polarity = "dark";

  stylix.base16Scheme =
    "${pkgs.base16-schemes}/share/themes/kanagawa-dragon.yaml";

  stylix.fonts = {
    monospace = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font Mono";
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
      terminal = 12;
      applications = 9;
    };
  };

  stylix.opacity.terminal = 0.90;

  stylix.targets.nixvim.enable = true;
}
