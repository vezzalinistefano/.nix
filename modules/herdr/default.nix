{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  home.packages = [
    inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.herdr
  ];

  # config.toml stays writable because herdr rewrites it (onboarding, Settings UI):
  # the repo copy only seeds it when absent.
  # Plugins are installed imperatively (pinned refs):
  #   herdr plugin install paulbkim-dev/vim-herdr-navigation --yes
  #   herdr plugin install thanhdat77/herdr-navigator --ref v0.3.6 --yes
  home.activation.herdrConfigSeed = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "$HOME/.config/herdr/config.toml" ]; then
      run mkdir -p "$HOME/.config/herdr"
      run install -m 644 ${./config.toml} "$HOME/.config/herdr/config.toml"
    fi
  '';
}
