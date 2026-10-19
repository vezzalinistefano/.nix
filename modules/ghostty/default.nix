{ ... }:
{
  programs = {
    ghostty = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        # Left Option acts as Alt (tmux M-h/j/k/l); right Option still types è/à
        macos-option-as-alt = "left";
      };
    };
  };
}
