{ pkgs, ... }:
{
  home.packages = with pkgs; [
    claude-code
  ];

  # Hook scripts only: settings.json stays hand-edited because Claude writes to it
  home.file.".claude/hooks/tmux-attention.sh" = {
    source = ./tmux-attention.sh;
    executable = true;
  };
}
