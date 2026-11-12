{
  config,
  pkgs,
  ...
}:
let
  user = config.system.primaryUser;

  # Apps symlinked by home-manager are not registered with LaunchServices, so
  # `open -a Ghostty` can't find the nix build: open it by store path instead.
  # The Homebrew cask lives in /Applications and is found by name.
  ghostty =
    if config.apps.ghostty.source == "nix" then
      ''"${pkgs.ghostty-bin}/Applications/Ghostty.app"''
    else
      "Ghostty";

  # Focus Ghostty if a herdr client is already attached, otherwise open a new
  # Ghostty window running herdr (it attaches to the persistent session, or starts it).
  # herdr comes from home-manager (modules/herdr), so use its per-user profile path.
  ghostty-herdr = pkgs.writeShellScript "ghostty-herdr" ''
    herdr="/etc/profiles/per-user/${user}/bin/herdr"

    # herdr is exec'd without a login shell, so TERMINFO_DIRS (set by /etc/zshrc) is
    # missing and it can't find xterm-ghostty ("missing or unsuitable terminal")
    export TERMINFO_DIRS="/etc/profiles/per-user/${user}/share/terminfo:/run/current-system/sw/share/terminfo"

    # A client's command line ends in "herdr"; the background server's ends in "server"
    if /bin/ps -axo command= | /usr/bin/grep -Eq '(^|/)herdr$'; then
      exec /usr/bin/open -a ${ghostty}
    fi

    exec /usr/bin/open -na ${ghostty} --args -e "$herdr"
  '';
in
{
  services = {
    skhd = {
      enable = true;
      # skhd needs Accessibility permission: System Settings > Privacy & Security
      # > Accessibility > allow skhd (prompted on first launch).
      skhdConfig = ''
        # Ghostty running herdr
        cmd + alt - return : ${ghostty-herdr}
      '';
    };
  };
}
