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
      modules-left = [ "hyprland/workspaces" ];
      modules-center = [
        "clock"
        "mpris"
      ];
      modules-right = [
        "tray"
        "hyprland/language"
        "network"
        "wireplumber"
        "battery"
      ];

      clock = {
        format = "{:%a %d %b  %H:%M}";
        tooltip = false;
      };
      # Current song from any player that speaks MPRIS (Spotifast does); click to play/pause
      mpris = {
        format = "{status_icon} {artist} - {title}";
        format-stopped = "";
        status-icons = {
          playing = ">";
          paused = "||";
        };
        max-length = 50;
        tooltip-format = "{player}: {album}";
      };
      # Needed by Spotifast to keep playing after its window is closed
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
      };
      wireplumber = {
        format = "vol {volume}%";
        format-muted = "muted";
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
