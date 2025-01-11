{ pkgs, ... }: {
  imports = [ ./tree-sitter.nix ./git.nix ];

  programs = {
    nixvim = {
      colorschemes = {
        gruvbox = {
          enable = true;
          settings = { transparent_mode = true; };
        };
      };
    };
  };
}
