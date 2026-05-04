{ pkgs, ... }:
{
  home.packages = with pkgs; [
    tfupdate
  ];
}
