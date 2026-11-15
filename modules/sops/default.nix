{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    sops
  ];

  # Same age key location on every OS (sops would look under ~/Library on macOS otherwise)
  home.sessionVariables.SOPS_AGE_KEY_FILE = "${config.xdg.configHome}/sops/age/keys.txt";
}
