#!/usr/bin/env python3
"""Check a base16 scheme against WCAG AAA (7:1) for the pairs the desktop uses.

Solid colours only: translucency (terminal opacity, bar pill alpha) is applied on
top at runtime and is not modelled here.

Usage: check-aaa-contrast.py [scheme.yaml ...]
With no arguments, every modules/stylix/schemes/*.yaml is checked.
Exit status is 1 if any pair is below 7.0, else 0.
"""

import glob
import os
import re
import sys

THRESHOLD = 7.0

# (foreground, background, label) pairs that actually appear on screen:
# text on the three background tiers, dim text, headings, the "pure" stops,
# every accent as text, and the inverse pills (urgent, clock, active workspace).
ACCENTS = ("base08", "base09", "base0A", "base0B", "base0C", "base0D", "base0E", "base0F")

PAIRS = [
    ("base05", "base00"),
    ("base05", "base01"),
    ("base05", "base02"),  # hover pill
    ("base04", "base00"),
    ("base04", "base01"),
    ("base06", "base00"),
    ("base07", "base00"),
    *[(accent, bg) for accent in ACCENTS for bg in ("base00", "base01")],
    ("base00", "base08"),  # urgent pill
    ("base00", "base0D"),  # clock pill
    ("base00", "base0E"),  # active workspace pill
]

PALETTE_LINE = re.compile(r'^\s+(base0[0-9A-F]):\s*"?(#[0-9a-fA-F]{6})"?\s*$')
HEADER_LINE = re.compile(r"^(\w+):\s*(.*)$")


def parse_scheme(path):
    """Parse the base16 nested YAML: header keys plus `palette:` entries."""
    meta = {}
    palette = {}
    in_palette = False
    with open(path, encoding="utf-8") as handle:
        for raw in handle:
            line = raw.rstrip("\n")
            if not line.strip() or line.lstrip().startswith("#"):
                continue
            stripped = line.strip()
            if stripped.startswith("palette:"):
                in_palette = True
                continue
            match = PALETTE_LINE.match(line)
            if in_palette and match:
                palette[match.group(1)] = match.group(2)
                continue
            if not in_palette:
                header = HEADER_LINE.match(stripped)
                if header:
                    meta[header.group(1)] = header.group(2).strip().strip("'\"")
    missing = [f"base0{i:X}" for i in range(16) if f"base0{i:X}" not in palette]
    if missing:
        raise SystemExit(f"{path}: missing {', '.join(missing)} in palette")
    return meta, palette


def channel(value):
    value /= 255.0
    return value / 12.92 if value <= 0.03928 else ((value + 0.055) / 1.055) ** 2.4


def luminance(hex_colour):
    """WCAG 2.x relative luminance of a #rrggbb colour."""
    hex_colour = hex_colour.lstrip("#")
    r, g, b = (int(hex_colour[i : i + 2], 16) for i in (0, 2, 4))
    return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b)


def contrast(fg_hex, bg_hex):
    """WCAG 2.x contrast ratio, symmetric, in [1, 21]."""
    first, second = luminance(fg_hex), luminance(bg_hex)
    lighter, darker = max(first, second), min(first, second)
    return (lighter + 0.05) / (darker + 0.05)


def check(path):
    meta, palette = parse_scheme(path)
    name = meta.get("name") or os.path.basename(path)
    variant = meta.get("variant") or "?"
    print(f"== {name} ({variant}) {path}")

    failures = 0
    worst = None  # (ratio, label)
    for fg, bg in PAIRS:
        ratio = contrast(palette[fg], palette[bg])
        label = f"{fg} on {bg}"
        status = "OK  " if ratio >= THRESHOLD else "FAIL"
        if ratio < THRESHOLD:
            failures += 1
        if worst is None or ratio < worst[0]:
            worst = (ratio, label)
        print(f"{status} {ratio:.2f} {label}")

    if worst:
        print(f"-- {name}: {'FAIL' if failures else 'PASS'} ({len(PAIRS)} pairs, {failures} failing) worst {worst[0]:.2f} {worst[1]}")
    return failures, worst


def default_paths():
    here = os.path.dirname(os.path.abspath(__file__))
    pattern = os.path.join(here, os.pardir, "modules", "stylix", "schemes", "*.yaml")
    return sorted(glob.glob(pattern))


def main(argv):
    paths = argv or default_paths()
    if not paths:
        print("no scheme files given and none found in modules/stylix/schemes/", file=sys.stderr)
        return 2
    total_failures = 0
    overall_worst = None
    for path in paths:
        if not os.path.exists(path):
            print(f"missing file: {path}", file=sys.stderr)
            return 2
        failures, worst = check(path)
        total_failures += failures
        if worst and (overall_worst is None or worst[0] < overall_worst[0]):
            overall_worst = (worst[0], f"{os.path.basename(path)}: {worst[1]}")
    if overall_worst:
        print(f"== overall: {'FAIL' if total_failures else 'PASS'} ({len(paths)} scheme(s), {total_failures} failing pair(s)) worst {overall_worst[0]:.2f} {overall_worst[1]}")
    return 1 if total_failures else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
