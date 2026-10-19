{ pkgs, ... }:

let
  tmux-dev-layout = pkgs.writeShellScriptBin "tmux-dev-layout" (
    builtins.readFile ./tmux-dev-layout.sh
  );
in
{
  home.packages = [ tmux-dev-layout ];

  programs = {
    tmux = {
      enable = true;
      focusEvents = true;
      baseIndex = 1;
      historyLimit = 10000;
      escapeTime = 0;
      keyMode = "vi";
      mouse = true;
      prefix = "C-a";
      terminal = "tmux-256color";
      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = resurrect;
          extraConfig = ''
            set -g @resurrect-strategy-nvim 'session'
            set -g @resurrect-processes '"~claude->claude --continue" lazygit'
          '';
        }
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '15'
          '';
        }
      ];
      extraConfig = ''
        # Shift+Enter & co. reach Claude Code; truecolor in Ghostty
        set -s extended-keys on
        set -as terminal-features ',xterm-ghostty:RGB:extkeys'
        # Let Claude Code's OSC notifications through to Ghostty
        set -g allow-passthrough on
        set -g set-clipboard on
        set -g renumber-windows on

        bind r source-file ~/.config/tmux/tmux.conf \; display "tmux.conf reloaded"

        bind \\ split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        bind C new-window -c "#{pane_current_path}"
        unbind '"'
        unbind %

        # Navigate panes with prefix key + Vim motions
        bind -r h select-pane -L
        bind -r j select-pane -D
        bind -r k select-pane -U
        bind -r l select-pane -R

        # Use Alt-{h,j,k,l} without prefix key to switch panes directly.
        bind -n M-h select-pane -L
        bind -n M-j select-pane -D
        bind -n M-k select-pane -U
        bind -n M-l select-pane -R

        # Vi-mode copy keybindings with platform-aware clipboard
        bind -T copy-mode-vi v send-keys -X begin-selection
        if-shell 'command -v pbcopy' \
          'bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"; bind -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "pbcopy"' \
          'bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"; bind -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"'

        set -g status on
        set -g status-interval 1
        set -g status-justify left
        set -g status-keys vi
        set -g status-left "[#S] "
        set -g status-left-length 100
        set -g status-left-style default
        set -g status-position bottom

        set -g status-right " [#[fg=colour76,bg=default]%T %F#[fg=white]] \
        [#[fg=colour69]󱃾 #(kubectl config current-context)#[fg=white]]"
        set -g status-right-length 140
        set -g status-right-style default
        set -g status-style fg=white,bg=colour233

        # Claude Code hooks ring the bell when waiting (see modules/claude-code)
        set -g monitor-bell on
        set -g bell-action other
        set -g window-status-bell-style 'fg=colour233,bg=colour214,bold'
        set -g window-status-format ' #I:#W#{?@claude, 󰚩,}#{window_flags} '
        set -g window-status-current-format ' #I:#W#{?@claude, 󰚩,}#{window_flags} '

        # Popups: lazygit, and a persistent scratch Claude per session (prefix a toggles)
        bind g display-popup -E -w 90% -h 90% -d "#{pane_current_path}" lazygit
        bind a if-shell -F '#{m:claude-*,#{session_name}}' \
          'detach-client' \
          'display-popup -E -w 85% -h 85% -d "#{pane_current_path}" "TMUX= tmux new-session -A -s \"claude-#{session_name}\" claude"'

        # nvim | claude split in the current window
        bind D run-shell 'tmux-dev-layout "#{pane_current_path}" "#{pane_id}"'
      '';
    };
  };
}

#
#  _____   __
# / __\ \ / /
# \__ \\ V /
# |___/ \_/
#
# Stefano Vezzalini dotfiles
#
# ~/.tmux.conf
#

# set -g default-terminal "tmux-256color"
# set -ag terminal-overrides ",xterm-256color:RGB"
# set -sg escape-time 0
#
# # -- Remap prefix from 'C-b' to 'C-a'
# unbind C-b
# set-option -g prefix C-a
# bind-key C-a send-prefix
#
# bind r source-file ~/.tmux.conf
# set -g base-index 1
#
# set -g mode-keys vi
# bind -T copy-mode-vi v send-keys -X begin-selection
# bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'
#
# # Scrollback history.
# set -g history-limit 10000
#
# set -g mouse on
# set -g base-index 1
#
# # No lag after ESC.
# set -sg escape-time 0
#
# # -- Split remaps
# bind \\ split-window -h -c "#{pane_current_path}"
# bind - split-window -v -c "#{pane_current_path}"
# unbind '"'
# unbind %
#
# # Navigate panes with prefix key + Vim motions
# bind -r h select-pane -L
# bind -r j select-pane -D
# bind -r k select-pane -U
# bind -r l select-pane -R
#
# # Use Alt-{h,j,k,l} without prefix key to switch panes directly.
# bind -n M-h select-pane -L
# bind -n M-j select-pane -D
# bind -n M-k select-pane -U
# bind -n M-l select-pane -R
#
# # Resize panes with <prefix>Ctrl-{h,j,k,l}.  Omit/adjust the number for
# # finer adjustments.
# bind -r C-h resize-pane -L 5
# bind -r C-j resize-pane -D 5
# bind -r C-k resize-pane -U 5
# bind -r C-l resize-pane -R 5
#
# set -g status on
# set -g status-interval 1
# set -g status-justify left
# set -g status-keys vi
# set -g status-left "[#S] "
# set -g status-left-length 100
# set -g status-left-style default
# set -g status-position bottom
#
# set -g status-right " [#[fg=colour76,bg=default]%T %F#[fg=white]] \
# [#[fg=colour69]󱃾 #(kubectl config current-context)#[fg=white]]"
# set -g status-right-length 140
# set -g status-right-style default
# set -g status-style fg=white,bg=colour233
