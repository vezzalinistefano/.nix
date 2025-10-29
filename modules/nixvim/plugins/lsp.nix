{ config, ... }:
let
  helpers = config.lib.nixvim;
in
{
  programs = {
    nixvim = {
      plugins = {
        lsp = {
          enable = true;

          keymaps = {
            silent = true;
            diagnostic = {
              "<leader>vd" = "open_float";
              "<leader>k" = "goto_next";
              "<leader>j" = "goto_prev";
            };
            lspBuf = {
              gd = "definition";
              K = "hover";
              gi = "implementation";
              "<C-i>" = "signature_help";
              "<leader>D" = "type_definition";
              "<leader>rn" = "rename";
              "<leader>ca" = "code_action";
              "gr" = "references";
            };

            extra = [
              {
                key = "<leader>f";
                action = helpers.mkRaw ''
                  function()
                      vim.lsp.buf.format { async = true }
                  end
                '';
              }
            ];
          };

          servers = {
            gopls.enable = true;
            lua_ls.enable = true;
            clangd.enable = true;
            jsonnet_ls.enable = true;

            pyright = {
              enable = true;
            };

            terraformls = {
              enable = true;
            };

            nil_ls = {
              enable = true;
              settings = {
                formatting = {
                  command = [ "nixfmt" ];
                };
              };
            };

            gitlab_ci_ls.enable = true;
          };
        };

        luasnip.enable = true;
        cmp-nvim-lsp.enable = true;
        cmp-buffer.enable = true;
        cmp-path.enable = true;

        lspkind = {
          enable = true;

          cmp = {
            enable = true;
            menu = {
              nvim_lsp = "[LSP]";
              nvim_lua = "[api]";
              path = "[path]";
              luasnip = "[snip]";
              buffer = "[buffer]";
              neorg = "[neorg]";
            };
          };
        };

        cmp = {
          enable = true;
          autoEnableSources = true;
          settings = {
            snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";

            mapping = {
              "<C-b>" = "cmp.mapping.scroll_docs(-4)";
              "<C-f>" = "cmp.mapping.scroll_docs(4)";
              "<C-Space>" = "cmp.mapping.complete()";
              "<C-e>" = "cmp.mapping.close()";
              "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
              "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
              "<CR>" = "cmp.mapping.confirm({ select = true })";
            };

            sources = [
              { name = "path"; }
              { name = "nvim_lsp"; }
              { name = "luasnip"; }
              {
                name = "buffer";
                # Words from other open buffers can also be suggested.
                option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
              }
              { name = "neorg"; }
            ];
          };

        };
      };

      opts.completeopt = [
        "menu"
        "menuone"
        "noselect"
      ];
    };
  };
}
