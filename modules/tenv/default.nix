{ pkgs, ... }:
{
  home.packages = with pkgs; [
    tenv
  ];
}
