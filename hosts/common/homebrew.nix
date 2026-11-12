{ ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      # "zap"/"uninstall" make nix-darwin call `brew bundle --cleanup`, which Homebrew 7 removed
      cleanup = "none";
      upgrade = true;
    };
    brews = [
      # Development tools
      "libpq"
      "opencode" # nixpkgs build broken (2.2.5 node_modules)
    ];
    casks = [
      # Applications that benefit from Homebrew's installation/update mechanism
      # Per-device scroll direction (not in nixpkgs); configured in modules/linearmouse
      "linearmouse"
    ];
    taps = [
      # Add custom taps if needed in future
    ];
    masApps = {
      # Mac App Store applications
    };
  };
}
