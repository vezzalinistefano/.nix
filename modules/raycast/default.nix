{
  pkgs,
  lib,
  osConfig,
  ...
}:
let
  switchable = import ../lib/mk-switchable-app.nix (import ./app.nix);

  # Nix builds are symlinked into ~/Applications and unknown to LaunchServices, so open by store path;
  # the Homebrew cask lives in /Applications.
  appPath =
    if osConfig.apps.raycast.source == "nix" then
      "${pkgs.raycast}/Applications/Raycast.app"
    else
      "/Applications/Raycast.app";

  # Show Spotlight search (symbolic hotkey 64) off, so Raycast can take Cmd+Space
  spotlightOff = "<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>1048576</integer></array><key>type</key><string>standard</string></dict></dict>";
in
{
  imports = [ switchable.home ];

  # Launch at login. Leave Raycast's own "Launch at login" setting off, or it starts twice.
  launchd.agents.raycast = {
    enable = true;
    config = {
      ProgramArguments = [
        "/usr/bin/open"
        "-a"
        appPath
      ];
      RunAtLoad = true;
      ProcessType = "Interactive";
    };
  };

  # Replace Spotlight: Raycast on Cmd+Space (Command-49 = Cmd + key code 49, space).
  # Takes effect after restarting Raycast / logging out; the Raycast hotkey is reset on each switch.
  home.activation.raycastDefaults = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run /usr/bin/defaults write com.raycast.macos raycastGlobalHotkey -string "Command-49"
    run /usr/bin/defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 '${spotlightOff}'
    run /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
}
