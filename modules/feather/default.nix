{ pkgs, ... }:
{
  # Monero wallet (light: it uses remote nodes, no blockchain download).
  # Only the app is installed: wallets and seed phrases are created on the machine
  # and never belong in this repository.
  home.packages = with pkgs; [
    feather
  ];
}
