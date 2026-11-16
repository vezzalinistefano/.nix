{ inputs, pkgs, ... }:
{
  # Linux half (home-manager): built from the upstream flake. Playback needs Spotify Premium.
  # macOS installs the Homebrew cask instead, see ./darwin.nix
  # Not in the NixOS cache, so callisto compiles it. Skipping its test suite halves that
  home.packages = [
    (inputs.spotifast.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs {
      doCheck = false;
    })
  ];
}
