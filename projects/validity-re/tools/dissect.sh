#!/usr/bin/env bash
# Read a capture through the Validity90 Lua dissector.
#
#   ./tools/fetch-dissector.sh                       # once
#   ./tools/dissect.sh captures/x.pcapng             # before the handshake: framing only
#   ./tools/dissect.sh captures/x.pcapng IN OUT      # after it: decrypt with session keys
#
# The keys are direction-relative (aes_in for traffic from the device, aes_out for traffic
# to it), because the two directions take different keys out of the key block. They change
# with every session, so a capture only decrypts with the keys derived during that session.
set -euo pipefail

here=$(dirname "$(readlink -f "$0")")
vendor=$here/vendor
capture=$(readlink -f "${1:?usage: $0 <capture.pcapng> [aes_in_hex] [aes_out_hex]}")
shift

[[ -f $vendor/lua-lockbox/dissector.lua ]] || { echo "run ./tools/fetch-dissector.sh first" >&2; exit 1; }

args=()
[[ -n ${1:-} ]] && args+=(-o "validity90.aes_in:${1}")
[[ -n ${2:-} ]] && args+=(-o "validity90.aes_out:${2}")

cd "$vendor/lua-lockbox"
tshark -r "$capture" "${args[@]}" \
  -Y 'usb.idVendor == 0x06cb && usb.idProduct == 0x009a' \
  -X "lua_script:dissector.lua" \
  -V 2>&1 | sed -n '/Validity90/,$p'
