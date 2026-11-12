{ ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    brews = [
      # Development tools
      "libpq"
    ];
    casks = [
      # Applications that benefit from Homebrew's installation/update mechanism
    ];
    taps = [
      # Add custom taps if needed in future
    ];
    masApps = {
      # Mac App Store applications
    };
  };
}
