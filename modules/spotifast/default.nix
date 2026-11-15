{ inputs, pkgs, ... }:
{
  # Linux half (home-manager): built from the upstream flake. Playback needs Spotify Premium.
  # macOS installs the Homebrew cask instead, see ./darwin.nix
  home.packages = [
    inputs.spotifast.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
