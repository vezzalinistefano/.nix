#!/usr/bin/env bash
# Stores a secret value (an API key, a token) in the encrypted secrets of a NixOS host.
# Usage: scripts/set-secret.sh <host> <name>      e.g.  callisto deepseek-api-key
# The value is typed or pasted hidden, and saved encrypted by sops; it is never shown.
set -euo pipefail

host=${1:?usage: set-secret.sh <host> <name>}
name=${2:?usage: set-secret.sh <host> <name>}
cd "$(dirname "$0")/.."
file="secrets/$host.yaml"
[ -e "$file" ] || { echo "$file does not exist yet." >&2; exit 1; }

read -r -s -p "Value for $name (hidden): " value
echo
[ -n "$value" ] || { echo "Empty value: nothing changed." >&2; exit 1; }

sops set "$file" "[\"$name\"]" "$(printf '%s' "$value" | jq -Rs .)"
unset value
echo "Saved $name in $file. Commit the file, then rebuild the host."
