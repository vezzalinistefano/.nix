# Pinned tooling for working on this repository: the formatter `nix fmt` calls, and the
# pre-commit framework whose hooks `.pre-commit-config.yaml` defines. Install the hook once
# per clone with `pre-commit install`.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nixfmt-tree
    pre-commit
  ];
}
