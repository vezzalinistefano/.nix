_: {
  # One thin bar: workspaces, clock, and the laptop basics. The palette (@baseXX) and the
  # font still come from stylix, but its default flat bar is replaced by the rules below.
  stylix.targets.waybar.addCss = false;
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = ''
      * {
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      /* Floating card, gapped off the screen edge like the notifications */
      window#waybar {
        background: alpha(@base00, 0.92);
        border: 2px solid @base02;
        border-radius: 10px;
        color: @base05;
        margin: 6px 8px;
      }

      tooltip {
        background: alpha(@base00, 0.95);
        border: 2px solid @base0D;
        border-radius: 10px;
        color: @base05;
      }

      .modules-left,
      .modules-center,
      .modules-right {
        padding: 2px 6px;
      }

      /* Quiet pills; only the time, the language and the urgent states get colour */
      #clock,
      #mpris,
      #tray,
      #language,
      #network,
      #wireplumber,
      #backlight,
      #battery {
        background: alpha(@base01, 0.85);
        border-radius: 8px;
        margin: 3px 2px;
        padding: 0 10px;
      }

      #clock {
        background: @base0D;
        color: @base00;
        font-weight: bold;
        padding: 0 14px;
      }

      #mpris {
        color: @base04;
      }
      #mpris.playing {
        color: @base05;
      }

      #language {
        color: @base0C;
        font-weight: bold;
      }

      #network.disconnected,
      #battery.warning {
        color: @base0A;
      }
      #battery.critical:not(.charging) {
        background: @base08;
        color: @base00;
      }
      #battery.charging,
      #battery.plugged {
        color: @base0B;
      }

      #wireplumber.muted {
        color: @base03;
      }

      #tray {
        padding: 0 6px;
      }
      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      /* Workspaces stay flat: the active one is the only filled pill */
      #workspaces {
        background: transparent;
        margin: 3px 2px;
      }
      #workspaces button {
        background: alpha(@base01, 0.85);
        border-radius: 8px;
        color: @base04;
        margin-right: 3px;
        padding: 0 9px;
      }
      #workspaces button:hover {
        background: @base02;
        color: @base05;
      }
      #workspaces button.active,
      #workspaces button.focused {
        background: @base0E;
        color: @base00;
      }
      #workspaces button.urgent {
        background: @base08;
        color: @base00;
      }
    '';
    settings.main = {
      layer = "top";
      position = "top";
      height = 28;
      spacing = 10;
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
