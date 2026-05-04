{ pkgs, ... }:
{
  home.packages = with pkgs; [
    tflint
  ];
}
