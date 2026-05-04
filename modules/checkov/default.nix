{ pkgs, ... }:
{
  home.packages = with pkgs; [
    checkov
  ];
}
