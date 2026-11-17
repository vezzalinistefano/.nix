# 04 — Where a driver can live

Two architectures exist. Pick deliberately.

## A. TOD driver, out of tree

libfprint hands a TOD ("Touch OEM Driver") driver a device and expects a shared object in `/usr/lib/libfprint-2/tod-1/`. `bingch/libfprint-tod-vfs0090` does this for 009a today: it verifies, cannot enroll, and needs calibration data compiled in from a python-validity run.

Pros: no libfprint release needed, small surface, callisto already loads one (`services.fingerprint-auth.backend = "libfprint-tod"`), and `driver/` in this lab builds in exactly that shape, so iteration is minutes.

Cons: TOD is an internal API, unversioned, and breaks between libfprint minors. Enrollment stays outside it. Nobody else benefits.

## B. In-tree driver

Phases 5+ of this work are almost exactly what MR !626 already implements: full session, pairing, enroll, match, delete, clear. If our goal is a driver that lasts, it should live there.

Pros: shipped to everyone, `fprintd` handles enroll, no calibration blob ritual, no Python daemon.

Cons: contributor review cycles, data files must be packaged separately (`libfprint-validity-data`), and ABI/behaviour has to satisfy a maintainer, not just our unit.

## Strategy for this lab

1. Learn on the TOD skeleton in `driver/`. It is throwaway by design and lets us poke one command at a time with a real device behind it.
2. Diff our findings against MR !626 and python-validity. Anything we observed and they did not is either a finding or our own bug — for 009a specifically the HAL parameters, calibration and pairing path matter.
3. Port the useful bits into !626 as patches and report with the capture attached.

The rule of thumb: **TOD for discovery, in-tree for delivery.** A TOD fork that only we run is a failure even if it works.

## What `driver/` contains, and what it deliberately does not

`driver/vcsfw.c` is a TOD entry point with the SSM skeleton, the `FpiDevice` struct, and the endpoint constants, but stubs where the session belongs. It reports `FP_DEVICE_ERROR_NOT_SUPPORTED` from every action, which fprintd renders as "device found, unusable" — exactly the right starting point: we can see our name in `fprintd-list` before writing a byte of protocol.

Check libfprint's own `libfprint/drivers/` for the shapes: `synaptics/` for a match-on-chip sibling, `goodixmoc/` for a state machine that does enrollment.
