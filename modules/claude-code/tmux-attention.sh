#!/usr/bin/env bash
# Claude Code hook: flag the tmux window whose Claude needs attention.
# Stop/Notification: ring the pane bell and set window option @claude=waiting.
# UserPromptSubmit (arg "clear"): unset @claude.
set -u

[ -n "${TMUX_PANE:-}" ] || exit 0

if [ "${1:-}" = "clear" ]; then
  tmux set-option -wu -t "$TMUX_PANE" @claude
  exit 0
fi

tmux set-option -w -t "$TMUX_PANE" @claude waiting
tty="$(tmux display -p -t "$TMUX_PANE" '#{pane_tty}')"
[ -w "$tty" ] && printf '\a' >"$tty"
exit 0
