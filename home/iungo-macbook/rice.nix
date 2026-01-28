{ pkgs, inputs, ... }:

{
  imports = [ inputs.stylix.homeModules.stylix ];
  stylix.enable = true;
  stylix.polarity = "dark";

  stylix.base16Scheme =
    "${pkgs.base16-schemes}/share/themes/pop.yaml";

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

    emoji = {
      name = "Apple Color Emoji";
    };
    sizes = {
      terminal = 12;
      applications = 9;
    };
  };

  stylix.opacity.terminal = 0.90;

  stylix.targets.nixvim.enable = false;
}
