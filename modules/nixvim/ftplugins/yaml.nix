{ ... }:

let
  ftpluginPathSuffix = "after/ftplugin/";
in
{
  programs = {
    nixvim = {
      files =
        let
          defaultOptions = {
            silent = true;
            noremap = true;
            buffer = true;
          };
        in
        {
          "${ftpluginPathSuffix}yaml.lua" = {
            keymaps = [
              {
                key = "<leader>yl";
                action = ":!yamllint %<CR>";

                options = defaultOptions;
              }
            ];
            localOpts = {
              foldmethod = "indent";
              foldlevel = 1;
            };
          };
        };
    };
  };
}
