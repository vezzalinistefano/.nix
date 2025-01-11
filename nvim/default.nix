{ inputs, ... }:

{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./keymaps.nix
    ./options.nix
    ./plugins
    ./autocommands.nix
  ];

  programs.nixvim = {
    enable = true;
    enableMan = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}
