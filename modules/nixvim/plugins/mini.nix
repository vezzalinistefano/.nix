{ config, ... }:
let
  helpers = config.lib.nixvim;
in
{
  programs = {
    nixvim = {
      plugins.mini = {
        enable = true;
        mockDevIcons = true;
        modules.icons = {
          style = "glyph";

          default = { };
          directory = { };
          extension = { };
          file = { };
          filetype = { };
          lsp = { };
          os = { };

          use_file_extension = helpers.mkRaw "function(ext, file) return true end";
        };

      };
    };
  };
}
