# 03 — Capturing without wrecking things

`usbmon` sits between the host controller and the device and copies transfers to a character device. It never writes to the reader, so a capture cannot damage an enrollment — but the *traffic* you capture while running the reference implementation can, because the reference implementation is the one doing the writing.

## Setup

```bash
sudo cp tools/99-vcsfw-lab.rules /etc/udev/rules.d/ && sudo udevadm control --reload
```

That grants your user uaccess on the reader (for pyusb) and keeps it out of autosuspend. It does not arbitrate: stop the daemons before you probe.

```bash
sudo modprobe usbmon
sudo systemctl stop python3-validity open-fprintd
sudo ./tools/capture.sh 60
```

In another terminal, with the daemons stopped, you cannot enroll — so for enrollment captures, restart the daemons *while the capture is running*:

```bash
# terminal 1
sudo ./tools/capture.sh 120
# terminal 2
sudo systemctl start python3-validity open-fprintd
fprintd-enroll
```

Record in `notes/NOTES.md`: what ran, in what order, and anything it printed.

## Filters

Capture everything on the bus, filter on read. `usbmon` has no BPF worth the name; `tshark -Y 'usb.idVendor == 0x06cb'` afterwards is exact and costs nothing.

Useful display filters:

| Filter | Shows |
| --- | --- |
| `usb.idVendor == 0x06cb && usb.idProduct == 0x009a` | only the reader |
| `usb.endpoint_address == 0x01` | what we sent |
| `usb.endpoint_address == 0x83` | interrupts |
| `usb.transfer_type == 0x03` | every interrupt transfer, all endpoints |
| `usb.urb_status != 0` | failed/aborted transfers, i.e. timeouts as a feature |

## Reading a plain capture

Before any key work, confirm the shape:

```bash
tshark -r captures/x.pcapng -Y 'usb.idVendor == 0x06cb' -T fields \
  -e usb.endpoint_address -e usb.capdata | head -20
```

You should see `0x01` with one byte, then `0x81` with a status+payload, and later `0x17 03 03` records. If an `0x81` read fails with `usb.urb_status == -71` (EPROTO), something else is holding the device.

## Sizing

- The device is chatty during capture: expect a few hundred KB for one enrollment. That is why `captures/` is gitignored and only distilled notes are committed.
- Cap with `capture.sh <seconds>`; an unbounded `tshark -w` on a laptop bus fills the disk with unrelated noise.

## Exercise

Make one capture of `fprintd-list` (short, no finger). From the `.pcapng` alone, list every request byte sequence in order. Compare with `tools/probe.py` output and explain any difference before running the probe.
