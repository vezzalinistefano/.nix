# Spotifast: native Rust Spotify client (https://github.com/crmne/spotifast).
# Not in nixpkgs; installed from the upstream Homebrew tap. Playback needs Spotify Premium.
_: {
  homebrew = {
    taps = [ "crmne/tap" ];
    casks = [ "crmne/tap/spotifast" ];
  };
}
