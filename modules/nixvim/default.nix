{ ... }:

{
  imports = [
    ./keymaps.nix
    ./options.nix
    ./plugins
    ./autocommands.nix
    ./filetypes.nix
    ./ftplugins
  ];

  programs.nixvim = {
    enable = true;
    enableMan = true;
    viAlias = true;
    vimAlias = true;
  };
}
