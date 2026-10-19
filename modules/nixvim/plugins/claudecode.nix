{ pkgs, ... }:
{
  programs.nixvim = {
    # coder/claudecode.nvim: IDE integration over the same protocol as the VS Code extension.
    # Claude runs in its own tmux pane and connects to this nvim with /ide.
    extraPlugins = [ pkgs.vimPlugins.claudecode-nvim ];

    extraConfigLua = ''
      require("claudecode").setup({
        terminal = { provider = "none" },
        log_level = "warn",
      })
    '';
  };
}
