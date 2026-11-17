{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ghq
  ];

  # ghq reads its root from git config. Keep the long-standing ~/projects
  # convention: repos land in ~/projects/<host>/<org>/<repo>, which is also
  # what the tmux-sessionizer in ../zsh scans by default.
  programs.git.settings.ghq.root = "~/projects";
}
