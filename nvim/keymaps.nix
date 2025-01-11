{ pkgs, config, ... }:
let helpers = config.lib.nixvim;
in {
  programs = {
    nixvim = {
      globals = {
        mapleader = " ";
        maplocalleader = " ";
      };

      keymaps = [
        # Move between splits
        {
          key = "<C-j>";
          action = "<C-w>j";
          options = {
            silent = true;
            noremap = true;
          };
        }
        {
          key = "<C-k>";
          action = "<C-w>k";
          options = {
            silent = true;
            noremap = true;
          };
        }
        {
          key = "<C-l>";
          action = "<C-w>l";
          options = {
            silent = true;
            noremap = true;
          };
        }
        {
          key = "<C-h>";
          action = "<C-w>h";
          options = {
            silent = true;
            noremap = true;
          };
        }
        # NetRw
        {
          key = "<leader>pv";
          action = helpers.mkRaw "vim.cmd.Ex";
          options = {
            silent = true;
            noremap = true;
          };
        }
        # Clipboard
        {
          key = "<leader>y";
          action = ''"+y'';
          options = {
            silent = true;
            noremap = true;
          };
          mode = [ "n" "v" ];
        }
      ];
    };
  };
}
