# Validity 06cb:009a — reverse engineering lab

A workspace to study how the ThinkPad T480 fingerprint reader talks, and to turn what we learn into a driver libfprint can load. **Teaching project**: the notes explain the reasoning, not just the commands, and every phase ends with a hypothesis to test rather than a result to copy.

This is lab work, not the production path. callisto currently runs the finished results of other people's version of this work (`modules/fingerprint`, python-validity, then the TOD fork). Nothing here changes the system until you say so.

## Ground rules

1. **Read prior art before writing code.** Everything below is built on three projects. They are the reference, and skipping them means re-deriving 2018:
   - [`nmikhailov/Validity90`](https://github.com/nmikhailov/Validity90) — init sequence spec draft, Wireshark dissector, libusb prototype (protocol level, stale but authoritative on framing).
   - [`uunicorn/python-validity`](https://github.com/uunicorn/python-validity) — working driver; `validitysensor/{usb,sensor,tls}.py` is the clearest description of the command set in existence.
   - [`libfprint` MR !626](https://gitlab.freedesktop.org/libfprint/libfprint/-/merge_requests/626) (continuing !579) — in-tree driver, TLS session, pairing, enrollment; claims this USB ID.
2. **The device is a black box with a rebuildable state.** Enrollment writes to on-chip flash. A factory reset or a bad pairing can wipe fingerprints, so note the state before and after each experiment.
3. **One writer at a time.** `python3-validity` and `open-fprintd` hold the device. Stop them before probing, start them again when done.
4. **Capture before theorising.** A hypothesis not backed by a `.pcapng` is a guess.

## Phases

| # | Phase | Artefact | Done when |
| --- | --- | --- | --- |
| 0 | Descriptors | `notes/descriptors-*.txt` | Every endpoint, interface and string is written down and understood |
| 1 | Init sequence | `captures/init-*.pcapng`, `notes/NOTES.md` | We can replay INIT_MSG1..3 and read the status words |
| 2 | Handshake | `captures/handshake-*.pcapng` | A live capture decrypts in Wireshark with the dissector, server random included |
| 3 | Framing | `notes/framing.md` | Request/response format, status codes and length fields are documented from data |
| 4 | Session keys | `tools/keystream.py` | The key block is reproduced from the master key + randoms, verified against a capture |
| 5 | Command set | `notes/commands.md` | GET_VERSION, LED, capture, match, enroll are each described by observed bytes |
| 6 | Driver | `driver/` | A TOD driver that opens, verifies and enrolls on this unit |
| 7 | Upstream | a patch or a bug report | Sent to MR !626 with the capture that shows it |

Phases 0-2 are read-only and safe. Phase 5 can brick the pairing; phase 6 is where it gets fun.

## Use

```bash
nix develop            # tooling shell
sudo systemctl stop python3-validity open-fprintd   # free the device
./tools/descriptors.py
sudo ./tools/capture.sh 30          # 30 s of traffic, then enroll with python-validity in another tty
./tools/dissect.sh captures/<file>.pcapng
```

`tools/probe.py` sends the first init commands on its own — run it once you have seen them in a capture and can predict the bytes.
