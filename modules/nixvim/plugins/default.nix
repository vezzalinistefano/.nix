{ pkgs, ... }:
let
  luaDisableBackground = ''
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" }) -- Optional: for floating windows
  '';
in
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
      extraConfigLua = luaDisableBackground;

      colorschemes = {
        cyberdream = {
          enable = false;
        };
        rose-pine = {
          enable = false;
        };
        gruvbox = {
          enable = true;
          settings = {
            transparent_mode = true;
          };
        };
        modus = {
          enable = false;
        };
      };
    };
  };
}
