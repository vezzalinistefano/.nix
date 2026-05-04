{ pkgs, ... }:
{
  home.packages = with pkgs; [
    pam-reattach
  ];
}
