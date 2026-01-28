{ pkgs, ... }:
{
  imports = [
    ./tree-sitter.nix
    ./git.nix
    ./lsp.nix
    ./lualine.nix
    ./harpoon.nix
    ./telescope.nix
    ./mini.nix
    ./nix.nix
    ./markdown.nix
  ];

  programs = {
    nixvim = {
      colorschemes = {
        cyberdream = {
          enable = true;
        };
        rose-pine = {
          enable = false;
          settings = {
            highlight_groups = {
              NormalFloat = {
                bg = "none";
              };
              Normal = {
                bg = "none";
              };
              NormalNC = {
                bg = "none";
              };
            };
          };
        };
        gruvbox = {
          enable = false;
          settings = {
            transparent_mode = true;
          };
        };
        modus = {
          enable = false;
        };
      };
      extraPlugins = [
        (pkgs.vimUtils.buildVimPlugin {
          name = "async.vim";
          src = pkgs.fetchFromGitHub {
            owner = "prabirshrestha";
            repo = "async.vim";
            rev = "2082d13bb195f3203d41a308b89417426a7deca1";
            hash = "sha256-YxZdOpV66YxNBACZRPugpk09+h42Sx/kjjDYPnOmqyI=";
          };
        })
        (pkgs.vimUtils.buildVimPlugin {
          name = "asyncomplete.vim";
          src = pkgs.fetchFromGitHub {
            owner = "prabirshrestha";
            repo = "asyncomplete.vim";
            rev = "17b654a87a834d4e835fb7467e562b4421ad9310";
            hash = "sha256-YxZdOpV66YxNBACZRPugpk09+h42Sx/kjjDYPnOmqyI=";
          };
        })
        (pkgs.vimUtils.buildVimPlugin {
          name = "asyncomplete-lsp.vim";
          src = pkgs.fetchFromGitHub {
            owner = "prabirshrestha";
            repo = "asyncomplete-lsp.vim";
            rev = "master";
            hash = "sha256-YxZdOpV66YxNBACZRPugpk09+h42Sx/kjjDYPnOmqyI=";
          };
        })
      ];
    };
  };
}
