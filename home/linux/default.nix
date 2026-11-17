# Linux desktop user configuration (on top of ../common): Hyprland and the few
# pieces around it, plus the GUI apps the Macs get through the switchable apps.
{ pkgs, ... }:
{
  imports = [
    ../../modules/awww
    ../../modules/claude-code
    ../../modules/direnv
    ../../modules/feather
    ../../modules/gpg-agent
    ../../modules/gpg-tui
    ../../modules/hyprland
    ../../modules/hyprpolkitagent
    ../../modules/hyprlock
    ../../modules/librewolf
    ../../modules/mako
    ../../modules/nautilus
    ../../modules/opencode
    ../../modules/udiskie
    ../../modules/vicinae
    ../../modules/vscodium
    ../../modules/waybar
  ];

  # One pointer theme and size everywhere (otherwise each toolkit picks its own)
  stylix.cursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };
  gtk.iconTheme = {
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
  };
  # Tell apps and websites that the desktop is dark
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  # Notification at 15% battery, again at 8%. -i: the removable BAT1 reports no
  # energy_full while it is empty, which otherwise aborts the daemon at start.
  services.batsignal = {
    enable = true;
    extraArgs = [
      "-i"
      "-w"
      "15"
      "-c"
      "8"
      "-d"
      "4"
    ];
  };

  home.packages = with pkgs; [
    btop
    pavucontrol
    telegram-desktop
  ];

  home.stateVersion = "26.05";
}
