{ ... }:

{
  programs = {
    obsidian = {
      enable = true;
    };
  };

  # Ensure the obsidian config directory exists by creating a dummy file
  xdg.configFile."obsidian/dummy" = {
    text = "";
    force = true;
  };
}
