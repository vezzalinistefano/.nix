{ pkgs, ... }:
{

  programs = {
    nixvim = {
      plugins = {
        treesitter = {
          enable = true;

          nixvimInjections = true;

          folding = true;
          settings = {
            indent.enable = true;
            highlight.enable = true;
            auto_install = true;
          };
        };
      };
    };
  };
}
