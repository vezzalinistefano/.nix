# Headless Linux user configuration (on top of ../common): just the shared
# tooling and the migration anchor. The desktop pieces (Hyprland and its apps)
# live in ../linux and are not imported on servers.
{ ... }:
{
  home.stateVersion = "26.05";
}
