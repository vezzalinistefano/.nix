#!/usr/bin/env python3
"""Dump the reader's USB descriptors, strings and endpoints.

Phase 0. Read-only: no control transfers beyond the standard ones pyusb needs, no
device state touched. Everything here is what the kernel already parsed, re-read
through libusb so we can see the interface layout a driver would have to live with.

Run it with the daemons stopped (see README) and note anything surprising:
  * which interface carries what,
  * whether the interrupt endpoint is on its own interface,
  * the bcdDevice / bNumConfigurations values,
  * string descriptors, which often name the silicon generation.
"""

import sys

import usb.core

VID, PID = 0x06CB, 0x009A


def strings(dev):
    """String descriptors. A missing one raises, so print only what reads."""
    for index in range(1, 8):
        try:
            value = usb.util.get_string(dev, index)
        except (usb.core.USBError, ValueError, NotImplementedError):
            continue
        print(f"  string[{index}] = {value!r}")


def main():
    dev = usb.core.find(idVendor=VID, idProduct=PID)
    if dev is None:
        sys.exit(f"no device {VID:04x}:{PID:04x} — is something else holding it?")

    print(f"device   {dev.idVendor:04x}:{dev.idProduct:04x}")
    print(f"bcdUSB   {dev.bcdUSB:#06x}")
    print(f"bcdDevice{dev.bcdDevice:#06x}")
    print(f"class    {dev.bDeviceClass:#04x} subclass {dev.bDeviceSubClass:#04x} proto {dev.bDeviceProtocol:#04x}")
    print(f"bus/addr {dev.bus}:{dev.address}  speed {dev.speed}  max packet 0 {dev.bMaxPacketSize0}")
    print(f"configs  {dev.bNumConfigurations}")
    strings(dev)

    for config in dev:
        print(f"\nconfiguration {config.bConfigurationValue}: {config.bmAttributes:#04x} {config.bMaxPower * 2} mA")
        for interface in config:
            print(
                f"  interface {interface.bInterfaceNumber} alt {interface.bAlternateSetting} "
                f"class {interface.bInterfaceClass:#04x}/{interface.bInterfaceSubClass:#04x}/"
                f"{interface.bInterfaceProtocol:#04x}"
            )
            for endpoint in interface:
                kind = {2: "bulk", 3: "interrupt", 1: "isochronous"}.get(endpoint.bmAttributes & 0x03, "control")
                direction = "in" if endpoint.bEndpointAddress & 0x80 else "out"
                print(f"    ep {endpoint.bEndpointAddress:#04x} {direction} {kind} max packet {endpoint.wMaxPacketSize}")

    if "--raw" in sys.argv[1:]:
        # The parsed view hides class-specific descriptors; fetch the raw configuration
        # and dump it. The parsed view above comes from sysfs, the raw read needs a handle
        # and therefore permissions — run this variant under sudo (or after installing
        # tools/99-vcsfw-lab.rules).
        try:
            raw = dev.ctrl_transfer(0x80, 0x06, 0x0200, 0, 9 + dev[0].wTotalLength)
        except usb.core.USBError as err:
            print(f"\nraw dump needs device access: {err}")
            print("  sudo ./tools/descriptors.py --raw")
            return
        print(f"\nraw configuration descriptor, {len(raw)} bytes")
        for offset in range(0, len(raw), 16):
            chunk = raw[offset : offset + 16]
            print(f"  {offset:04x}  {' '.join(f'{b:02x}' for b in chunk)}")


if __name__ == "__main__":
    main()
