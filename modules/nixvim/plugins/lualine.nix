{
  programs = {
    nixvim = {
      plugins = {
        lualine = {
          enable = true;
          settings = {
            sections = {
              lualine_a = [
                "mode"
              ];
              lualine_b = [
                "branch"
                "diff"
              ];
              lualine_c = [
                {
                  __unkeyed-1 = "diagnostics";
                  sources = [
                    "nvim_diagnostic"
                  ];
                  sections = [
                    "error"
                    "warn"
                    "info"
                    "hint"
                  ];
                  symbols = {
                    error = " ";
                    warn = " ";
                    info = " ";
                    hint = " ";
                  };
                }
                {
                  __unkeyed-1 = "filename";
                  path = 1;
                  shorting_target = 50;
                }
              ];
              lualine_x = [
                {
                  __unkeyed-1 = {
                    __raw = ''
                      function()
                        local msg = 'No LSP'
                        local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
                        local clients = vim.lsp.get_clients()
                        if next(clients) == nil then return msg end
                        for _, client in ipairs(clients) do
                          local filetypes = client.config.filetypes
                          if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                            return client.name
                          end
                        end
                        return msg
                      end
                    '';
                  };
                  icon = " LSP:";
                }
                "encoding"
                "fileformat"
                "filetype"
              ];
              lualine_y = [
                "progress"
              ];
              lualine_z = [
                "location"
              ];
            };
          };
        };
      };
    };
  };
}
