_: {
  # Lock screen: a plain background and a password field (colours from stylix)
  programs.hyprlock = {
    enable = true;
    settings = {
      general.hide_cursor = true;
      input-field = {
        size = "300, 40";
        outline_thickness = 1;
        rounding = 0;
        fade_on_empty = false;
        placeholder_text = "";
      };
    };
  };

  # Lock after 5 minutes, screen off after 6, suspend after 15 on battery only (plugged in
  # it stays reachable over SSH); always lock before sleep
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 360;
          on-timeout = "hyprctl dispatch 'hl.dsp.dpms({ action = \"off\" })'";
          on-resume = "hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'";
        }
        {
          timeout = 900;
          on-timeout = "systemd-ac-power || systemctl suspend";
        }
      ];
    };
  };
}
