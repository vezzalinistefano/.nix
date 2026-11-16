{ pkgs, ... }:
{
  # `bw`: the Bitwarden command line client, for reading and saving vault items from scripts
  home.packages = with pkgs; [
    bitwarden-cli
  ];
}
