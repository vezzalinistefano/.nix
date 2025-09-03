{ pkgs, inputs, ... }:

{
  imports = [ inputs.stylix.homeManagerModules.stylix ];
  stylix.enable = true;
  stylix.polarity = "dark";

  stylix.base16Scheme =
    "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";

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
      terminal = 12;
      applications = 9;
    };
  };

  stylix.opacity.terminal = 0.95;

  stylix.targets.nixvim.enable = false;
}
