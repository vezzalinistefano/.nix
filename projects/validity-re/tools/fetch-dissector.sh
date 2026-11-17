#!/usr/bin/env bash
# Fetch the Validity90 dissector and its lua-lockbox dependency into tools/vendor.
#
# Both are vendored (gitignored), not committed: LGPL-2.1 code, and a dissector that
# silently changes under you is worse than none. Re-run to update.
#
# The dissector does `require("lockbox.util.array")` with the path `./lockbox/?.lua`, so
# lua-lockbox is checked out where its own inner `lockbox/` dir sits next to the script
# and tools/dissect.sh runs tshark from that directory.
set -euo pipefail

here=$(dirname "$(readlink -f "$0")")
vendor=$here/vendor

mkdir -p "$vendor"
echo "fetching Validity90 (spec.md, dissector, prototype)"
git clone --depth 1 https://github.com/nmikhailov/Validity90 "$vendor/Validity90"

echo "fetching lua-lockbox"
git clone --depth 1 https://github.com/somesocks/lua-lockbox "$vendor/lua-lockbox"

# dissector.lua expects ../lockbox? No: it appends "./lockbox/?.lua" to package.path and
# the lockbox checkout's inner directory is named lockbox, so run it from inside it.
cp "$vendor/Validity90/dissector.lua" "$vendor/lua-lockbox/dissector.lua"

echo "done."
echo "  spec:       $vendor/Validity90/spec.md"
echo "  dissector:  $vendor/lua-lockbox/dissector.lua"
