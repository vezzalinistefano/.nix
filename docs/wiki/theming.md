# Theming (WCAG AAA dark + light)

**ABOUTME:** The two base16 schemes behind stylix, the contrast guarantee, and how to switch
the desktop between dark and light on callisto.

## The schemes

| File | Variant | Used by |
| --- | --- | --- |
| `modules/stylix/schemes/svn-aaa-dark.yaml` | dark | every host (default) |
| `modules/stylix/schemes/svn-aaa-light.yaml` | light | callisto, `light` specialisation |

They are plain base16 YAML files in the same nested format as `pkgs.base16-schemes`, so they
feed stylix like any upstream theme (`modules/stylix/default.nix` points `base16Scheme` at the
dark one with `lib.mkDefault`). Everything stylix themes follows automatically: Hyprland, waybar,
mako, hyprlock, GTK/Qt, terminals, bat, btop…

Design: a cool near-black background with light text (dark) and an off-white background with
dark text (light). Accents are muted on purpose — on a light background a saturated colour
cannot reach 7:1, so the light accents are deep teal/forest/plum/navy/olive.

## The AAA guarantee

WCAG AAA asks for a contrast ratio of at least **7:1** for normal text. The palettes are chosen so
every pair actually rendered on screen clears it:

- primary/secondary text on the three background tiers,
- every accent as text on the bar background and on the bar pills,
- the inverse pills: clock (`base0D`), urgent (`base08`), active workspace (`base0E`).

`base03` is a background-tier colour (borders, disabled states, terminal "bright black") and is
intentionally not used as text anywhere.

Check it locally (also runs in CI as `checks.contrast`):

```bash
python3 scripts/check-aaa-contrast.py        # both schemes in modules/stylix/schemes/
nix build .#checks.x86_64-linux.contrast     # the same, as a flake check
```

The check fails below 7.0, so change a palette value until it passes. When adding waybar CSS,
only use `base04`/`base05` (or an accent that passes the checker) for text; colour pairs are
listed in `PAIRS` in the script.

**Caveat — translucency.** The guarantee is for solid colours. The terminal runs at 90%
opacity and the bar pills use alpha, so over a bright wallpaper the *effective* contrast can dip
below 7:1. Set `stylix.opacity.terminal = 1.0` (and drop the `alpha()` calls in
`modules/waybar/default.nix`) for a strict guarantee.

## Switching dark ↔ light on callisto

The light theme is a NixOS specialisation (`hosts/callisto/theme.nix`), so both variants are
built together and switching is instant — no rebuild, and the daily `release` auto-upgrade keeps
working:

```bash
sudo /run/current-system/specialisation/light/bin/switch-to-configuration switch   # light
sudo /run/current-system/bin/switch-to-configuration switch                        # back to dark
```

dconf's `color-scheme` follows `stylix.polarity`, so GTK apps and websites flip too. The Macs
have no specialisation mechanism: they stay on SVAAA-Dark.

Wallpapers are rotated at random from `~/Pictures/Wallpapers`; keep a light-friendly image in
there if the light variant looks wrong against dark art.

## Waybar icons

The bar uses Material Design glyphs from Hack Nerd Font (resolved from Nerd Fonts'
`glyphnames.json`, cmap-verified): wi-fi/ethernet/offline, volume/muted, brightness, battery,
charging, and play/pause for the MPRIS module. The glyph characters live in the `format`
strings in `modules/waybar/default.nix`.
