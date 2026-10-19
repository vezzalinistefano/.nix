#!/usr/bin/env bash
# Tests tmux-attention.sh against a throwaway tmux server.
# Usage: bash modules/claude-code/tmux-attention.test.sh
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
script="$here/tmux-attention.sh"
socket="tmux-attention-test-$$"
failures=0

cleanup() {
  tmux -L "$socket" kill-server 2>/dev/null || true
}
trap cleanup EXIT

assert_eq() {
  if [ "$1" != "$2" ]; then
    echo "FAIL: $3 (expected '$2', got '$1')"
    failures=$((failures + 1))
  else
    echo "ok: $3"
  fi
}

tmux -L "$socket" -f /dev/null new-session -d -s test
pane="$(tmux -L "$socket" display -p -t test '#{pane_id}')"
socket_path="$(tmux -L "$socket" display -p '#{socket_path}')"

claude_state() {
  tmux -L "$socket" show -wqv -t "$pane" @claude
}

# Without $TMUX_PANE the script must do nothing and succeed
env -u TMUX -u TMUX_PANE bash "$script" </dev/null
assert_eq "$?" "0" "no-op exits 0 outside tmux"
assert_eq "$(claude_state)" "" "no-op leaves @claude unset"

# Hooks receive JSON on stdin: the script must not block on it
echo '{"hook_event_name":"Stop"}' |
  TMUX="$socket_path,0,0" TMUX_PANE="$pane" bash "$script"
assert_eq "$(claude_state)" "waiting" "marks window as waiting"

echo '{"hook_event_name":"UserPromptSubmit"}' |
  TMUX="$socket_path,0,0" TMUX_PANE="$pane" bash "$script" clear
assert_eq "$(claude_state)" "" "clear unsets @claude"

[ "$failures" -eq 0 ] && echo "all tests passed" || exit 1
