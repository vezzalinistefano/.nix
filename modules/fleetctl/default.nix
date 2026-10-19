{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fleetctl
  ];
}
