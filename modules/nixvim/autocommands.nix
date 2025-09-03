{ pkgs, config, ... }:
let
  helpers = config.lib.nixvim;
in
{
  programs = {
    nixvim = {
      autoGroups = {
        StefanoVezzaliniGroup = { };
        StefanoVezzaliniFugitive = { };
      };

      autoCmd = [
        {
          event = [ "FileType" ];
          pattern = [
            "gitcommit"
            "markdown"
          ];
          group = "StefanoVezzaliniGroup";
          callback = helpers.mkRaw ''
            function()
                vim.opt_local.wrap = true
                vim.opt_local.spell = true
            end
          '';
        }
        {
          event = [ "BufWinEnter" ];
          pattern = "*";
          group = "StefanoVezzaliniGroup";
          callback = helpers.mkRaw ''
            function()
                if vim.bo.ft ~= "fugitive" then
                    return
                end

                local bufnr = vim.api.nvim_get_current_buf()
                local opts = {buffer = bufnr, remap = false}
                vim.keymap.set("n", "<leader>p", function()
                    vim.cmd.Git('push')
                end, opts)

                -- rebase always
                vim.keymap.set("n", "<leader>P", function()
                    vim.cmd.Git({'pull',  '--rebase'})
                end, opts)

                -- NOTE: It allows me to easily set the branch i am pushing and any tracking
                -- needed if i did not set the branch up correctly
                vim.keymap.set("n", "<leader>t", ":Git push -u origin ", opts);
            end
          '';
        }
      ];
    };
  };
}
