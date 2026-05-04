{ pkgs, ... }:
{
  home.packages = with pkgs; [
    jsonnet
  ];
}
