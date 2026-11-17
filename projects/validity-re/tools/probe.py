#!/usr/bin/env python3
"""Send the opening init commands to the reader and print what comes back.

Phase 1. This mirrors python-validity's `Usb.send_init` steps 1-3 and nothing else: we
want the replies to the first three commands, on their own, before the 0x1e2-byte blob
of INIT_MSG4 goes in. Copying a known-good sequence is deliberate — the point of phase 1
is to confirm our framing against a reference implementation, not to discover framing.

Wire model (from prior art, confirmed against `validitysensor/usb.py`):

  * bulk OUT, endpoint 0x01, carries the request. Raw bytes, no length prefix.
  * bulk IN, endpoint 0x81, carries the answer to that request.
  * bulk IN, endpoint 0x82, is a second channel python-validity reads separately.
  * interrupt IN, endpoint 0x83, reports scan/finger events.
  * every command answer starts with a little-endian 16-bit status; 0 is success.

So the rule is: one write to 0x01, one read from 0x81, parse status, then look at the
payload. Reads are matched to writes by order — there is no request id to correlate on,
which is why only one process may hold the device.

Stop the daemons before running this (README, ground rule 3), or the reads will hang
waiting for answers that went to the other process.
"""

import struct
import sys

import usb.core
import usb.util

VID, PID = 0x06CB, 0x009A
EP_OUT, EP_IN = 0x01, 0x81
TIMEOUT_MS = 15_000

# INIT_MSG1..3 from the Validity90 spec appendix B. The payloads after these get long
# (INIT_MSG4 is a 0x1e2-byte blob, INIT_MSG5/6 carry TLS material), so they stay out of
# phase 1.
PROBES = [
    ("INIT_MSG1 / RomInfo.get", "01"),
    ("INIT_MSG2", "19"),
    ("INIT_MSG3 / get_fw_info", "4302"),
]


def hexdump(data: bytes, width: int = 16) -> str:
    """Offset, hex, ascii — the only output format worth reading at 3 a.m."""
    lines = []
    for offset in range(0, len(data), width):
        chunk = data[offset : offset + width]
        hexpart = " ".join(f"{b:02x}" for b in chunk)
        text = "".join(chr(b) if 32 <= b < 127 else "." for b in chunk)
        lines.append(f"  {offset:04x}  {hexpart:<{width * 3}}  |{text}|")
    return "\n".join(lines)


def main() -> int:
    dev = usb.core.find(idVendor=VID, idProduct=PID)
    if dev is None:
        print(f"no device {VID:04x}:{PID:04x}", file=sys.stderr)
        return 1

    try:
        dev.set_configuration()
    except usb.core.USBError as err:
        # Already configured (the kernel or a daemon got there first) is fine
        print(f"set_configuration: {err}")

    dev.default_timeout = TIMEOUT_MS
    print(f"probing {VID:04x}:{PID:04x} on bus {dev.bus} addr {dev.address}\n")

    for label, hexbytes in PROBES:
        request = bytes.fromhex(hexbytes)
        print(f"> {label}   {hexbytes}")
        try:
            dev.write(EP_OUT, request)
            response = bytes(dev.read(EP_IN, 1024 * 100))
        except usb.core.USBError as err:
            print(f"  failed: {err}\n")
            return 2

        status = struct.unpack("<H", response[:2])[0]
        print(f"< {len(response)} bytes, status {status:#06x}")
        print(hexdump(response))
        print()

    # Leave the reader in a defined state rather than half-initialised: python-validity
    # resets the device on close, and so do we.
    try:
        dev.reset()
    except usb.core.USBError as err:
        print(f"reset: {err}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
