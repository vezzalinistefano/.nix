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
  ];

  programs = {
    nixvim = {
      colorschemes = {
        gruvbox = {
          enable = true;
          settings = {
            transparent_mode = true;
          };
        };
      };
    };
  };
}
