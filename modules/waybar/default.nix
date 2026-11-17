_: {
  # One thin bar: workspaces, clock, and the laptop basics. Colours and font come from stylix.
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings.main = {
      layer = "top";
      position = "top";
      height = 24;
      spacing = 12;
      # The song sits on the left so the clock does not move when the title changes
      modules-left = [
        "hyprland/workspaces"
        "mpris"
      ];
      modules-center = [ "clock" ];
      modules-right = [
        "tray"
        "hyprland/language"
        "network"
        "wireplumber"
        "backlight"
        "battery"
      ];

      clock = {
        format = "{:%a %d %b  %H:%M}";
        tooltip = false;
      };
      # Current song from any player that speaks MPRIS; click to play/pause
      mpris = {
        format = "{status_icon} {artist} - {title}";
        format-stopped = "";
        status-icons = {
          playing = ">";
          paused = "||";
        };
        max-length = 40;
        tooltip-format = "{player}: {album}";
      };
      # Icons of apps that keep running after their window is closed
      tray = {
        icon-size = 14;
        spacing = 8;
      };
      "hyprland/language" = {
        format-it = "it";
        format-en = "us";
      };
      network = {
        format-wifi = "{essid} {signalStrength}%";
        format-ethernet = "eth";
        format-disconnected = "offline";
        tooltip-format = "{ifname} {ipaddr}";
        # Click: pick a Wi-Fi network
        on-click = "ghostty -e nmtui";
      };
      wireplumber = {
        format = "vol {volume}%";
        format-muted = "muted";
        # Click: choose outputs and per-app volume
        on-click = "pavucontrol";
      };
      # Screen brightness, so the brightness keys show their effect
      backlight = {
        format = "bri {percent}%";
        tooltip = false;
      };
      battery = {
        format = "bat {capacity}%";
        format-charging = "chg {capacity}%";
        states = {
          warning = 20;
          critical = 10;
        };
      };
    };
  };
}
