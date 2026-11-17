# Lab notebook

Newest entry on top. One entry per experiment: what we changed, what we expected, what happened. A capture with no entry is worthless in a week.

Format:

```
## YYYY-MM-DD — <one line>
state before: <enrolled? paired? daemons running?>
did:          <commands, in order>
expected:     <the hypothesis, stated so it can be wrong>
observed:     <bytes, statuses, capture file name>
conclusion:   <confirmed / refuted / inconclusive + next step>
```

## 2026-11-17 — phase 0, parsed descriptors

state before: daemons inactive, device idle.
did: `./tools/descriptors.py`.
expected: one interface, the three endpoints python-validity uses (0x01/0x81/0x82) plus the 0x83 interrupt.
observed: `bcdDevice 0x0164`, class `ff/10/ff`, one configuration, 100 mA, `ep 0x01` out bulk, `0x81 0x82` in bulk, `0x83` in interrupt/8 bytes **and `0x84` in interrupt/16 bytes** — an endpoint the reference implementation never reads.
conclusion: `0x84` is unaccounted for; could be a second event channel (Windows Hello notifications?) or a debug trace. Watch it in the first capture with `usb.endpoint_address == 0x84` and log whatever arrives. The raw descriptor dump is still pending (needs sudo).

## 2026-11-17 — workspace created

state before: device never enumerated by anything of ours; python-validity not yet installed on this generation.
did: nothing yet.
expected: —
observed: —
conclusion: start at phase 0: `sudo systemctl stop python3-validity open-fprintd`, then `./tools/descriptors.py`, then a 20 s capture of `fprintd-list`.

## Open questions

- Does the device answer at all when the daemons are stopped, or does opening it need the probe to be the only holder *and* a fresh reset?
- Which interface is the interrupt endpoint on? If it is a separate interface, the driver has to claim it explicitly.
- Is `0x82` a real second channel or just a longer-read byproduct?
- Which of INIT_MSG4/5/6 reply fields are seed, which are certificates, which are noise?
- What does the firmware version report for this unit, and does it differ from the EU/other variants in the spec?
