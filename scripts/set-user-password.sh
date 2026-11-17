#!/usr/bin/env bash
# Stores a user's login password (as a hash) in the encrypted secrets of a NixOS host.
# Usage: scripts/set-user-password.sh <host> <user>      e.g.  callisto sv
# The password is asked twice and never shown; only its hash is saved, encrypted by sops.
# It takes effect when the account is created (a reinstall). On a running machine use `passwd`.
set -euo pipefail

host=${1:?usage: set-user-password.sh <host> <user>}
user=${2:?usage: set-user-password.sh <host> <user>}
cd "$(dirname "$0")/.."
file="secrets/$host.yaml"
key="$user-password"

# SHA-512 crypt: understood by every Linux; openssl asks for the password twice
hash=$(nix shell nixpkgs#openssl --command openssl passwd -6)
# shellcheck disable=SC2016  # the '$6$' prefix must not expand
case $hash in '$6$'*) ;; *) echo "No hash was produced: nothing changed." >&2; exit 1 ;; esac

mkdir -p secrets
if [ -e "$file" ]; then
  sops set "$file" "[\"$key\"]" "$(printf '%s' "$hash" | jq -Rs .)"
else
  printf '%s: %s\n' "$key" "$(printf '%s' "$hash" | jq -Rs .)" |
    sops encrypt --filename-override "$file" --input-type yaml --output-type yaml /dev/stdin >"$file.tmp"
  mv "$file.tmp" "$file"
fi
echo "Saved $key in $file. Commit the file, then deploy the host."
