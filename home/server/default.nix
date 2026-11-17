# Headless Linux user configuration (on top of ../common): just the shared
# tooling and the migration anchor. The desktop pieces (Hyprland and its apps)
# live in ../linux and are not imported on servers.
{ ... }:
{
  home.stateVersion = "26.05";

  # No graphical session, so no D-Bus session bus: the dconf activation step
  # (`dconf load` talking to that bus) fails, and home-manager reports the whole
  # activation as failed. The settings only exist because ../common pulls in
  # stylix for fonts and colours, which a server does not paint anywhere.
  dconf.enable = false;
}
