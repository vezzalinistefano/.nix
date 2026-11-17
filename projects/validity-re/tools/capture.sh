#!/usr/bin/env bash
# Capture USB traffic for the reader on its own bus.
#
# usbmon gives one character device per bus; the reader is on a fixed bus, so we log
# the whole bus and filter afterwards. Nothing is written to the reader: usbmon taps
# between the host controller and the device.
#
#   sudo ./tools/capture.sh 30              # 30 seconds, everything on the bus
#   sudo ./tools/capture.sh 30 1-9          # also only that device (tshark filter below)
#
# While it runs, do the thing in another terminal: `fprintd-enroll`, `fprintd-verify`,
# or a run of ./tools/probe.py. Say in notes/NOTES.md what you were doing.
set -euo pipefail

here=$(dirname "$(readlink -f "$0")")
captures=$here/../captures
duration=${1:-30}
mkdir -p "$captures"

if [[ $EUID -ne 0 ]]; then
  echo "usbmon needs root: sudo $0 $*" >&2
  exit 1
fi

modprobe usbmon

# The bus the reader sits on, from sysfs (no lsusb dependency)
bus=
for dev in /sys/bus/usb/devices/*; do
  [[ -r $dev/idVendor ]] || continue
  if [[ $(<"$dev/idVendor") == 06cb ]] && [[ $(<"$dev/idProduct") == 009a ]]; then
    bus=$(<"$dev/busnum")
    break
  fi
done
[[ -n $bus ]] || { echo "reader 06cb:009a not found on any bus" >&2; exit 1; }

out=$captures/$(date +%Y%m%d-%H%M%S)-usbmon${bus}.pcapng
echo "recording bus $bus for ${duration}s -> $out"
tshark -q -i "usbmon${bus}" -w "$out" -a "duration:${duration}"
echo "captured. dissect it:  ./tools/dissect.sh ${out#"$here/../"}"
