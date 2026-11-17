# 02 — The "TLS" layer

The transport is a hand-rolled, mildly broken TLS 1.2. It is *not* TLS enough to hand to OpenSSL unmodified, which is why both surviving implementations (python-validity and the TOD fork) open-code it. Get this layer right and the rest of the device is ordinary protocol work; get it wrong and everything after the handshake is noise.

## What it actually is

- Cipher suite `TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA` (`0xc005`) and nothing else.
- Client sends a fixed 4-byte prefix `44 00 00 00` before the ClientHello — a transport quirk, not TLS.
- ServerHello is 45 bytes, and "random" in later derivations is taken from the server's, not the client's, as normal TLS would.
- `CertificateRequest` and `Certificate` use vendor formats, and `CertificateVerify` omits the algorithm bytes.
- Padding is a PKCS#7 lookalike with every value shifted by one: `00`, `01 01`, `02 02 02`, …
- Records are `content-type 17` / `16` / `14` + `03 03` + big-endian length.

## Where the keys come from

This is the part worth understanding before touching bytes:

1. The host gets a **main seed** from the sensor during INIT_MSG6 (offset `0x11a`, 0x20 bytes). On 009a there is a fallback path that derives from the machine's DMI serial if the seed differs from the known test value.
2. `master_key = PRF(pre_master, "GWK", main_seed)` — HMAC-SHA256 in PRF2 shape, as in `TLS_PRF2`.
3. An ECDSA key is derived from that seed, used to sign the CertificateVerify.
4. The pre-master secret comes from an ECDHE exchange against `STATIC_KEY_ECDSA_DEV_PUB` style flash material, and both sides derive the key block from it.

So the seed is per-device state recovered from the device's own flash, and part of the handshake proves the host knows it. A capture from *our* unit cannot be decrypted without *our* unit's keys — which is why the capture and key extraction phases are separate deliverables.

## Key block layout

The TOD fork keeps a 0x120-byte key block and slices it:

| Slice | Use |
| --- | --- |
| `0x00..0x20` | HMAC key for records from device to host |
| `0x20..0x40` | AES key for records from device to host |
| `0x40..0x60` | HMAC key for records host to device |
| `0x60..0x80` | AES key for records host to device |
| `0x80..0xa0` | IV for device to host |
| `0xa0..0xc0` | IV for host to device |

`mac_then_encrypt()` in `vfs0090.c` builds the MAC over header + payload, appends AES-CBC ciphertext, and every record re-uses the next 0x10 bytes of IV rather than a chained IV. Match that exactly: the device is unforgiving about both order and padding.

## Reading the dissector

`dissect.lua` takes two preferences, `aes_in` and `aes_out` (direction-relative), plus `partial` when a record is split across USB transfers. Once a session's keys are known:

```bash
./tools/dissect.sh captures/enroll.pcapng <aes_in> <aes_out>
```

and every record renders as its decrypted payload. Before the keys, you still get the record structure and the plaintext init traffic.

## Why bother

Two reasons. First, the payload is where the command set lives — without decryption the capture is a wall of ciphertext. Second, reproducing the derivation ourselves is the check that we understand it: if our derived keys do not open a capture taken while a reference implementation ran, the derivation is wrong, and that is a fast, cheap, safe signal.

## Exercise

Take one capture of `fprintd-enroll`. Find the record that contains the master key derivation step. Without deriving anything yet, mark: the byte range of the server random, of the seed, and of the "GWK" label in the reference source. Then predict the first 16 bytes of the key block with a standalone Python script and compare once the derivation is in place.
