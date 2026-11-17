# .nix

Nix flake for Stefano Vezzalini's machines: a nix-darwin Mac (`SWS000135`), one NixOS
ThinkPad (`callisto`, Hyprland) and one headless NixOS server (`jupiter`), all fully
declared, sharing one home-manager configuration through a small set of per-platform
layers.

`AGENTS.md` describes the layout and the conventions in detail; `docs/wiki/` holds the
runbooks (new host, NixOS host, apps, GPG). Read those before changing a host.

## Rebuilding

```bash
# the Mac, from this checkout at /private/etc/nix-darwin
drs            # switch
drb            # build only

# callisto: from a Mac, over SSH (callisto builds and switches itself)
nrs callisto
nrt callisto   # activate without making it the boot default

# jupiter (headless server): same commands, with the sudo password of sv
nrs jupiter

# callisto updates itself daily from the `release` branch
```

`release` only moves for commits whose CI on `main` passed, so a broken push never reaches
the laptop. Run the checks before pushing:

```bash
nix flake check     # formatting, scripts, flake structure
nix fmt             # format
```

## Secrets

Encrypted with sops (`secrets/`, recipients in `.sops.yaml`), decrypted at activation by
sops-nix on the NixOS host. `scripts/set-secret.sh` stores a value; never commit plaintext.

## Not included

The flake pins `nixpkgs-unstable`; `home.stateVersion` / `system.stateVersion` are the
migration anchors and are only moved forward deliberately.

## License

MIT, see [LICENSE](LICENSE).
