{ pkgs, ... }:
{
  # Keeps unlocked GPG keys in memory and asks for the passphrase in a small window.
  # Linux only: the Macs get their passphrase window from modules/pinentry-mac.
  # See docs/wiki/gpg-vademecum.md
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-qt;
    # Ask for the passphrase again after 1 hour idle, and at the latest after 8 hours
    defaultCacheTtl = 3600;
    maxCacheTtl = 28800;
    # Let scripts hand the agent a passphrase up front (gpg-preset-passphrase), so sops
    # and other non-interactive callers never have to wait for the window.
    extraConfig = ''
      allow-preset-passphrase
    '';
  };
}
