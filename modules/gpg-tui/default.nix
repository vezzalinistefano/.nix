{ pkgs, ... }:
{
  # `gpg-tui`: a keyboard-driven frontend for the local keyring (list and inspect keys,
  # import and export, encrypt, decrypt and sign files). It shells out to gpg and the
  # running gpg-agent, so the passphrase window still comes from modules/gpg-agent.
  # See docs/wiki/gpg-vademecum.md
  home.packages = with pkgs; [
    gpg-tui
  ];
}
