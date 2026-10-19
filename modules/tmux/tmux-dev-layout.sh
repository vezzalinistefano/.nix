#!/usr/bin/env bash
# Turn a tmux window into the dev layout: nvim on the left, claude on the right (40%).
# Usage: tmux-dev-layout [dir] [target-pane]
set -euo pipefail

dir="${1:-$PWD}"
target="${2:-$(tmux display -p '#{pane_id}')}"

claude_pane="$(tmux split-window -h -l 40% -d -t "$target" -c "$dir" -P -F '#{pane_id}')"
tmux send-keys -t "$claude_pane" 'claude' Enter
tmux send-keys -t "$target" 'nvim .' Enter
