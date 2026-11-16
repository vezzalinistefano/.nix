{ pkgs, ... }:
{
  # macOS window that asks for the GPG passphrase (it can save it in the Keychain).
  # Without it, signing a commit from an editor or a tool with no terminal fails.
  # callisto uses modules/gpg-agent instead.
  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry_mac}/bin/pinentry-mac
    default-cache-ttl 3600
    max-cache-ttl 28800
  '';
}
