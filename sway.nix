{ lib, pkgs, ... }:
let
  modifier = "Mod4";
  output = "DP-2";
  opacity = "1.0";

  # navigation
  left = "h";
  down = "j";
  up = "k";
  right = "l";

in {
  home.packages = with pkgs; [ swaylock swayidle font-awesome ];

  programs.wpaperd = let wallpaper = "./backgrounds/wallhaven-p96odm.png";
  in {
    enable = true;
    settings = {
      default = {
        path = "${wallpaper}";
        apply-shadow = false;
      };
    };
  };

  programs.ghostty = {
    enable = true;
    settings = {
      window-padding-x = 10;
      window-padding-y = 10;
      window-decoration = false;
    };
  };

  programs.i3status-rust = {
    enable = true;
    bars = {
      default = {
        icons = "awesome6";
        theme = "srcery";
      };
    };
  };

  services.mako = {
    enable = true;
    defaultTimeout = 5000; # 5s
  };

  programs.rofi = {
    enable = true;
    extraConfig = {
      modi = "window,drun,run,ssh";
      show-icons = true;
      terminal = "ghostty";
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    checkConfig = true;
    config = {
      terminal = "ghostty";
      modifier = modifier;
      bars = [{
        statusCommand =
          "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-default.toml";
      }];
      gaps = {
        inner = 15;
        outer = 10;
        bottom = 5;
      };
      startup = [{ command = "${pkgs.wpaperd}/bin/wpaperd"; }];
      window = {
        border = 3;
        titlebar = false;
      };
      workspaceOutputAssign = let
        first = "DP-2";
        second = "HDMI-A-1";
      in [
        {
          output = first;
          workspace = "1";
        }
        {
          output = first;
          workspace = "2";
        }
        {
          output = first;
          workspace = "3";
        }
        {
          output = first;
          workspace = "4";
        }
        {
          output = first;
          workspace = "5";
        }
        {
          output = first;
          workspace = "6";
        }
        {
          output = second;
          workspace = "7";
        }
        {
          output = second;
          workspace = "8";
        }
        {
          output = second;
          workspace = "9";
        }
        {
          output = second;
          workspace = "10";
        }
      ];
      keybindings = lib.mkOptionDefault {
        # terminal
        "${modifier}+Return" = "exec ${pkgs.ghostty}/bin/ghostty";
        "${modifier}+Shift+Return" =
          "exec ${pkgs.ghostty}/bin/ghostty -e tmux new-session -A -s Default";
        # kill current window
        "${modifier}+q" = "kill";
        # lock screen
        "Control+Alt+l" = "exec ${pkgs.swaylock}/bin/swaylock -f -c 000000";
        # sticky window
        "${modifier}+Shift+y" = "sticky toggle";

        # rofi: menu
        "${modifier}+d" = ''
          exec ${pkgs.rofi}/bin/rofi -show drun 
        '';
      };
    };
  };
}
