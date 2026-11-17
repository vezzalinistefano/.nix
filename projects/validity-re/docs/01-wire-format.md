# 01 — Wire format

Everything here comes from `validitysensor/usb.py` and `tls.py` in python-validity and from the Validity90 spec draft. Read the code, not just this page: this is a summary, and summaries lose the caveats.

## Shape of a session

```
host                                       reader
 |  INIT_MSG1..3, INIT_MSG4 (blob)   ->      |
 |  <-  status words, 6 init replies         |
 |  ClientHello (4-byte 44 00 00 00 prefix) ->|
 |  <-  ServerHello + cert request           |
 |  Certificate, ECDHE pubkey, cert verify ->|
 |  <-  ChangeCipherSpec, Finished           |
 |  (everything below is TLS records)        |
 |  0x02 capture  ->  ... <-  interrupts      |
```

Four endpoints, all on the one interface:

| Endpoint | Direction | Type | Carries |
| --- | --- | --- | --- |
| `0x01` | out | bulk | every request, raw |
| `0x81` | in | bulk | the answer to that request |
| `0x82` | in | bulk | second channel, read separately (capture payload) |
| `0x83` | in | interrupt | scan/event records: `00` started, `02` finger present, `03` state update with a flag byte |

There is **no framing on the host side**: one write, one read, matched by order. USB already delimits transfers, so a length prefix would be redundant. That also means a lost or late answer desynchronises the session — the driver needs strict sequencing.

## Status words

Every answer starts with a little-endian `uint16`:

- `0x0000` success.
- `0x044f` signature validation failed (firmware extension rejected).
- anything else: failure, print it in hex.

`unhexlify`-style callers in python-validity call `assert_status(response)` before touching the payload. Do the same: a payload read out of a failure response is garbage.

## Command ids

The first byte is the verb. Ones we know from the reference implementation:

| Byte | Meaning | Wrapped in TLS? |
| --- | --- | --- |
| `0x01` | RomInfo / version | no |
| `0x19` | init step 2 | no |
| `0x43` | firmware info (`4302`, `02` = fwext partition) | no |
| `0x06` | init step 4 (carries the blob) | no |
| `0x3e` | init step 5 | no |
| `0x40` | init step 6 | no |
| `0x44` | flash read | yes, after `06 02` write-enable |
| `0x39` | LED pattern | yes |
| `0x02` | start capture (built per mode) | yes |
| `0x04` | stop capture, cleanup | yes |
| `0x51` | progress/status poll | yes |
| `0x5e` | match finger | yes |
| `0x60` | read match result | yes |
| `0x62` | cleanup after match | yes |
| `0x68`/`0x69`/`0x6b` | enrollment update start/begin-end/update | yes |

"Wrapped in TLS" means the request is a TLS application-record (`0x17 03 03 len …`), AES-CBC with an HMAC, not raw bytes. Sending a raw `0x02` after the handshake gets either silence or a status you cannot parse.

## Why the answers are variable length

They carry TLV-ish structures, and several of them start with a `uint32`/`uint16` payload length that must match the rest of the answer (`l != len(res)` checks in `capture()` and `match_finger()`). Treat a length mismatch as a protocol error, not as something to pad.

## Interrupt records are not answers

`wait_int()` polls `0x83` with a 100 ms timeout in a loop and dispatches on the first byte. They arrive asynchronously with respect to requests: a capture is `0x02` → interrupt `00` → interrupt `02` when skin is detected → interrupts `03` (bit `0x04` in the third byte means "capture complete") → then you poll `0x51` for the result. Reading `0x82` instead of `0x83` means blocking forever.

## Exercise

Take a capture of `fprintd-enroll` and, without looking at python-validity again, write down: the exact byte sequence of the first three requests, the status of each answer, and how many bytes of plaintext precede the first `17 03 03` record. Check yourself against the code afterwards.
