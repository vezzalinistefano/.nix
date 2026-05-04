{ config, ... }:
let
  helpers = config.lib.nixvim;
in
{
  programs = {
    nixvim = {
      globals = {
        mapleader = " ";
        maplocalleader = " ";
      };

      keymaps = [
        # NetRw
        {
          key = "<leader>pv";
          action = helpers.mkRaw "vim.cmd.Ex";
          options = {
            silent = true;
            noremap = true;
          };
        }
        # Git
        {
          key = "<leader>gs";
          action = ":vert G<CR>";
          options = {
            silent = true;
            noremap = true;
          };
        }
        # Git - Gwrite
        {
          key = "<leader>gw";
          action = ":Gwrite<CR>:q<CR>";
          options = {
            silent = true;
            noremap = true;
          };
        }
        # Git rebase continue
        {
          key = "<leader>grc";
          action = ":G rebase --continue<CR>";
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
          mode = [
            "n"
            "v"
          ];
        }
        # Telescope search (live grep)
        {
          action = ":Telescope live_grep<CR>";
          key = "<leader>sg";
          options = {
            silent = true;
            noremap = true;
            desc = "Search grep";
          };
        }
        # Telescope search buffers
        {
          action = ":Telescope buffers<CR>";
          key = "<leader>sb";
          options = {
            silent = true;
            noremap = true;
            desc = "Search buffers";
          };
        }
        # Telescope buffer
        {
          action = ":Telescope current_buffer_fuzzy_find<CR>";
          key = "<leader>b";
          options = {
            silent = true;
            noremap = true;
            desc = "Search current buffer";
          };
        }
        # Telescope command history
        {
          action = ":Telescope command_history<CR>";
          key = "<leader>sh";
          options = {
            silent = true;
            noremap = true;
            desc = "Search command history";
          };
        }
        # Telescope search files
        {
          action = ":Telescope find_files<CR>";
          key = "<leader>sf";
          options = {
            silent = true;
            noremap = true;
            desc = "Search files";
          };
        }
        # Telescope search commands
        {
          action = ":Telescope commands<CR>";
          key = "<leader>sc";
          options = {
            silent = true;
            noremap = true;
            desc = "Search commands";
          };
        }
        # Telescope diagnostics
        {
          action = ":Telescope diagnostics<CR>";
          key = "<leader>d";
          options = {
            silent = true;
            noremap = true;
            desc = "Diagnostics";
          };
        }
        # Telescope quickfixlist
        {
          action = ":Telescope quickfix<CR>";
          key = "<leader>ql";
          options = {
            silent = true;
            noremap = true;
            desc = "Quickfix list";
          };
        }
        # Telescope undo tree
        {
          action = ":Telescope undo<CR>";
          key = "<leader>u";
          options = {
            silent = true;
            noremap = true;
            desc = "Undo tree";
          };
        }
        # Harpoon add
        {
          action = helpers.mkRaw ''
            function()
              require("harpoon"):list():add()
            end
          '';
          key = "<leader>a";
          options = {
            silent = true;
            noremap = true;
            desc = "Harpoon add file";
          };
        }
        # Harpoon menu
        {
          action = helpers.mkRaw ''
            function()
              local harpoon = require("harpoon")
              harpoon.ui:toggle_quick_menu(harpoon:list())
            end
          '';
          key = "<leader>e";
          options = {
            silent = true;
            noremap = true;
            desc = "Harpoon menu";
          };
        }
        # Harpoon nav file 1
        {
          action = helpers.mkRaw ''
            function()
              require("harpoon"):list():select(1)
            end
          '';
          key = "<leader>1";
          options = {
            silent = true;
            noremap = true;
            desc = "Harpoon nav file 1";
          };
        }
        # Harpoon nav file 2
        {
          action = helpers.mkRaw ''
            function()
              require("harpoon"):list():select(2)
            end
          '';
          key = "<leader>2";
          options = {
            silent = true;
            noremap = true;
            desc = "Harpoon nav file 2";
          };
        }
        # Harpoon nav file 3
        {
          action = helpers.mkRaw ''
            function()
              require("harpoon"):list():select(3)
            end
          '';
          key = "<leader>3";
          options = {
            silent = true;
            noremap = true;
            desc = "Harpoon nav file 3";
          };
        }
        # Harpoon nav file 4
        {
          action = helpers.mkRaw ''
            function()
              require("harpoon"):list():select(4)
            end
          '';
          key = "<leader>4";
          options = {
            silent = true;
            noremap = true;
            desc = "Harpoon nav file 4";
          };
        }
      ];
    };
  };
}
