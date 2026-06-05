{ config, ... }:
let
  helpers = config.lib.nixvim;
in
{
  programs = {
    nixvim = {
      plugins = {
        fugitive = {
          enable = true;
        };

        gitsigns = {
          enable = true;
          settings = {
            signs = {
              add = { text = "▎"; };
              change = { text = "▎"; };
              delete = { text = ""; };
              topdelete = { text = ""; };
              changedelete = { text = "▎"; };
            };
            on_attach = helpers.mkRaw ''
              function(bufnr)
                local gs = package.loaded.gitsigns
                local opts = { buffer = bufnr, noremap = true, silent = true }

                vim.keymap.set("n", "]c", function()
                  if vim.wo.diff then return "]c" end
                  vim.schedule(function() gs.next_hunk() end)
                  return "<Ignore>"
                end, { expr = true, buffer = bufnr })

                vim.keymap.set("n", "[c", function()
                  if vim.wo.diff then return "[c" end
                  vim.schedule(function() gs.prev_hunk() end)
                  return "<Ignore>"
                end, { expr = true, buffer = bufnr })

                vim.keymap.set({ "n", "v" }, "<leader>hs", gs.stage_hunk, opts)
                vim.keymap.set({ "n", "v" }, "<leader>hr", gs.reset_hunk, opts)
                vim.keymap.set("n", "<leader>hS", gs.stage_buffer, opts)
                vim.keymap.set("n", "<leader>hR", gs.reset_buffer, opts)
                vim.keymap.set("n", "<leader>hu", gs.undo_stage_hunk, opts)
                vim.keymap.set("n", "<leader>hp", gs.preview_hunk, opts)
                vim.keymap.set("n", "<leader>hb", function() gs.blame_line({ full = true }) end, opts)
              end
            '';
          };
        };

        diffview = {
          enable = true;
        };
      };
    };
  };
}
