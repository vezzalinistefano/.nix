{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gotest
  ];
}
