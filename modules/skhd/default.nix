{ pkgs, ... }:
let
  # Focus Ghostty if the "default" tmux session already has a client attached,
  # otherwise open a new Ghostty window attached to it (created on first use).
  ghostty-tmux-default = pkgs.writeShellScript "ghostty-tmux-default" ''
    tmux="${pkgs.tmux}/bin/tmux"

    if "$tmux" has-session -t=default 2>/dev/null \
      && [ -n "$("$tmux" list-clients -t default 2>/dev/null)" ]; then
      exec /usr/bin/open -a Ghostty
    fi

    exec /usr/bin/open -na Ghostty --args -e "$tmux" new-session -A -s default
  '';
in
{
  services = {
    skhd = {
      enable = true;
      # skhd needs Accessibility permission: System Settings > Privacy & Security
      # > Accessibility > allow skhd (prompted on first launch).
      skhdConfig = ''
        # Ghostty attached to the "default" tmux session
        cmd + alt - return : ${ghostty-tmux-default}
      '';
    };
  };
}
