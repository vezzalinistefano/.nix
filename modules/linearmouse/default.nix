_: {
  # The app itself is the `linearmouse` Homebrew cask (hosts/common/homebrew.nix).
  # It reverses scrolling for mice only; the trackpad keeps the system direction.
  # First run: grant LinearMouse Accessibility access in System Settings > Privacy & Security.
  xdg.configFile."linearmouse/linearmouse.json".text = builtins.toJSON {
    "$schema" = "https://schema.linearmouse.app/0.10.0";
    schemes = [
      {
        "if" = {
          device = {
            category = "mouse";
          };
        };
        scrolling = {
          reverse = {
            vertical = true;
          };
        };
      }
    ];
  };

  launchd.agents.linearmouse = {
    enable = true;
    config = {
      ProgramArguments = [
        "/usr/bin/open"
        "-a"
        "/Applications/LinearMouse.app"
      ];
      RunAtLoad = true;
      ProcessType = "Interactive";
    };
  };
}
