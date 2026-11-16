{ inputs, ... }:

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
    # Build the plugins from this flake's nixpkgs (one copy for everything), said explicitly
    # so nixvim does not warn that its own pin was replaced
    nixpkgs.source = inputs.nixpkgs;
  };
}
