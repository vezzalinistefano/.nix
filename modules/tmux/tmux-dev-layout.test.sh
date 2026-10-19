#!/usr/bin/env bash
# Tests tmux-dev-layout.sh against a throwaway tmux server.
# Usage: bash modules/tmux/tmux-dev-layout.test.sh
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
script="$here/tmux-dev-layout.sh"
socket="tmux-dev-layout-test-$$"
dir="$(mktemp -d)"
failures=0

cleanup() {
  tmux -L "$socket" kill-server 2>/dev/null || true
  rm -rf "$dir"
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

# Wraps tmux so the script under test talks to the throwaway server
bin="$(mktemp -d)"
trap 'cleanup; rm -rf "$bin"' EXIT
printf '#!/bin/sh\nexec %s -L %s "$@"\n' "$(command -v tmux)" "$socket" >"$bin/tmux"
chmod +x "$bin/tmux"

pane="$(PATH="$bin:$PATH" tmux -f /dev/null new-session -d -x 200 -y 50 -P -F '#{pane_id}' -s test -c "$dir")"
PATH="$bin:$PATH" bash "$script" "$dir" "$pane"

assert_eq "$(tmux -L "$socket" list-panes -t test | wc -l | tr -d ' ')" "2" "splits window in two panes"
assert_eq "$(tmux -L "$socket" display -p -t test '#{pane_id}')" "$pane" "focus stays on the editor pane"

right="$(tmux -L "$socket" list-panes -t test -F '#{pane_id} #{pane_width} #{pane_current_path}' | grep -v "^$pane ")"
width="$(echo "$right" | awk '{ print $2 }')"
[ "$width" -ge 75 ] && [ "$width" -le 85 ] && ok=yes || ok=no
assert_eq "$ok" "yes" "claude pane is ~40% wide (got $width)"
assert_eq "$(cd "$(echo "$right" | awk '{ print $3 }')" && pwd -P)" "$(cd "$dir" && pwd -P)" "claude pane starts in project dir"

[ "$failures" -eq 0 ] && echo "all tests passed" || exit 1
