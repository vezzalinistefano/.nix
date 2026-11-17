# Installing and updating jupiter (headless NixOS server)

jupiter is a **physical x86_64 server** (Giga-byte board, AMD Ryzen 5 2600,
15 GiB RAM) used as the home server. It is headless: no desktop, key-only SSH and
`jupiter.local` through avahi. It currently runs **Proxmox 9** on the NVMe
(hostname `solaris`, static `192.168.1.35`), which is what the install replaces.

It is **not** the `vezzalini.org` machine: that name resolves locally to
`192.168.8.154`, a separate host that stays as it is.

Installed with [nixos-anywhere](https://github.com/nix-community/nixos-anywhere),
then it updates itself from the `release` branch: the deploying machine evaluates
the flake, jupiter builds and switches its own system.

> Verify the commands against the current upstream docs if something fails, since
> nixos-anywhere changes.

## 0. Where things live

| What | Where |
| --- | --- |
| System configuration | `hosts/jupiter/default.nix` |
| Disk layout (GPT + ESP + ext4, no LUKS) | `hosts/jupiter/disko.nix` |
| Hardware scan | `hosts/jupiter/hardware-configuration.nix` (placeholder, regenerated at install) |
| User configuration shared with the other hosts | `home/common/` |
| Headless user layer (no Hyprland) | `home/server/` |
| Flake entry | `mkNixosHost { hostname = "jupiter"; desktop = false; }` |

`desktop = false` keeps the desktop layer (`home/linux`, Hyprland, waybar,
mako…) off the server; `home/common` still gives it the shared shell, tmux,
nixvim and dev tooling.

## 1. What the machine is today

Read from the machine itself before the install (2026-11-17):

| | |
| --- | --- |
| Board / CPU | Giga-byte, AMD Ryzen 5 2600 (6 cores), 15 GiB RAM, KVM-capable |
| NIC | `e0:d5:5e:ae:b3:a1` (Realtek on the board, PCI `04:00.0`) |
| OS | **Proxmox VE 9.1.4**, hostname `solaris` |
| Network | static `192.168.1.35/24` (gateway `.1.1` does not exist: **no internet**; reachable from the LAN only over IPv6 link-local) |
| Boot | **UEFI** (Secure Boot **disabled**) |
| NVMe `nvme0n1` 1TB | Proxmox: ESP, LVM (`pve-root` 96G, `pve-data` 816G) → **wiped** |
| SATA `sda` 500G | Samsung, **Windows** (user `Vezza`, ~244G used) → **untouched** |
| VMs | 100 `docker-services` (= `arrakis.lan`, `192.168.8.145`) → **wiped** |

`disko.nix` only targets `nvme0n1`; the Windows disk keeps its own EFI partition
and firmware entry.

Because the host has no internet, the kexec tarball cannot be downloaded by the
host itself: download it on the deploying machine and pass it with `--kexec`.

## 2. Install (once, wipes the Proxmox NVMe)

### 2.1 Prerequisites

1. **Reachability.** The host has no usable IPv4 (only the dead `192.168.1.35`).
   Give it a lease on the LAN first, which is also the address the NixOS installer
   will ask for again after kexec (same MAC, same DHCP server):

   ```bash
   # on the Proxmox host, as root
   dhclient -1 -v vmbr0        # e.g. bound to 192.168.8.181
   ```

   Or use a DHCP reservation in the router for `e0:d5:5e:ae:b3:a1`, which also
   makes the final address of jupiter predictable.

2. **SSH.** `root` with a password works today; nixos-anywhere installs its own
   temporary key. Secure Boot is already off, nothing to change in the BIOS.

3. **Disk check.** `lsblk`: the layout assumes `/dev/nvme0n1` (Proxmox) and never
   touches `/dev/sda` (Windows). **Everything on the NVMe is erased**, including
   the `docker-services`/`arrakis` VM.

### 2.2 Run nixos-anywhere

```bash
cd ~/.nix
# GitHub is only reachable from the deploying machine: hand the tarball over
curl -fL -o /tmp/opencode/nixos-kexec.tar.gz \
  https://github.com/nix-community/nixos-images/releases/download/nixos-25.11/nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz

nix run github:nix-community/nixos-anywhere -- \
  --flake .#jupiter \
  --kexec /tmp/opencode/nixos-kexec.tar.gz \
  --generate-hardware-config nixos-generate-config ./hosts/jupiter/hardware-configuration.nix \
  --env-password \
  --target-host root@<lease-IP>
```

- `--kexec <file>` uploads the installer over SSH; without it the host tries
  GitHub and fails (`No route to host`).
- `--env-password` reads the password of `root` from `SSHPASS`.
- No `--disk-encryption-keys`: jupiter has no LUKS, so a reboot needs nothing
  typed on a keyboard (see the comments in `disko.nix` to add it later).
- No `--build-on remote`: the deploying NixOS machine builds the system itself.

When it finishes the machine reboots into NixOS. Then commit the generated scan:

```bash
git add hosts/jupiter/hardware-configuration.nix
git commit -m "chore(jupiter): hardware scan from the install"
```

Without `--generate-hardware-config` the placeholder file stays in place and the
machine likely will not boot, since it has almost no kernel modules.

### If it does not boot

- **Reconnect after kexec failed**: the installer runs, but at another address.
  Nothing has been wiped yet: power-cycle the machine and it boots Proxmox again,
  then retry with a DHCP reservation.
- **Wrong disk name**: disko fails before touching anything; fix `device` in
  `disko.nix`.
- The machine has a physical console: the NixOS boot menu and any error show
  there.

## 3. First login

```bash
ssh sv@jupiter.local      # or ssh sv@<lease-IP>
```

- The SSH host key changed with the install: `ssh-keygen -R <lease-IP>` and
  `ssh-keygen -R jupiter.local` if ssh complains.
- sudo asks for the password of `sv`: set it once on the machine with `passwd`
  (it lands in `/etc/shadow`, which is mutable, so it survives deployments and
  never enters the repo). SSH is key-only, so that password is only used by
  `sudo` and by the physical console. `nrs jupiter` prompts for it.
- To rotate it: `ssh -t sv@jupiter.local passwd`.
- Allowed keys today: `SWS000135` and `callisto`. Add another machine's
  `~/.ssh/id_ed25519.pub` to `users.users.sv.openssh.authorizedKeys.keys` in
  `hosts/jupiter/default.nix` and deploy.

## 4. Update

### Automatically

`system.autoUpgrade` in `hosts/jupiter/default.nix` follows
`github:vezzalinistefano/.nix/release#jupiter`, the branch CI only advances for a
green `main`. Once a day (or at the next boot if it was off) jupiter builds what
was pushed and switches. So: edit, commit, push to `main`, done. It never reboots
by itself.

```bash
sudo systemctl start nixos-upgrade     # on jupiter: do it now instead of waiting
journalctl -u nixos-upgrade -e         # what the last run did
systemctl list-timers nixos-upgrade    # when the next run is
```

### By hand, from another machine

```bash
nrs jupiter          # build on jupiter and switch
nrt jupiter          # build and activate, but a reboot goes back to the previous system
```

Both are the `nixos-deploy` function in `modules/zsh`: they use
`sv@jupiter.local` and fall back to a given destination if `.local` does not
resolve:

```bash
nrs jupiter sv@<lease-IP>
```

New files must be `git add`ed first, as for the other hosts.

Rollback: `sudo nixos-rebuild switch --rollback` on jupiter.

## 5. Secrets (not set up yet)

jupiter has no sops secrets and does not import sops-nix. That is deliberate: its
age key is derived from the SSH host key, which only exists after the install, and
an activation that cannot decrypt a secret fails. When the first secret is needed:

1. On the deploying machine: `ssh-keyscan jupiter.local | ssh-to-age` (the
   `ssh-to-age` binary is in the `sops` tooling of `home/common`), then add it to
   `.sops.yaml` as `&age_jupiter` and to a creation rule for
   `secrets/jupiter.yaml` (the catch-all rule is enough if the secret is not
   personal; callisto's rule is the model).
2. Import `inputs.sops-nix.nixosModules.sops` in `hosts/jupiter/default.nix` and
   add a `sops` block like callisto's, with
   `age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ]`.
3. `scripts/set-secret.sh jupiter <name>`, commit, `nrs jupiter`.

A `sv` password stored the callisto way (`hashedPasswordFile`, set with
`scripts/set-user-password.sh jupiter sv`) only applies when the account is
created, so on a running machine use `passwd` instead.

## 6. Manual steps after the install

- **DHCP reservation** for `e0:d5:5e:ae:b3:a1` in the router, if not done before.
- **Windows**: the Samsung disk still has its firmware entry; pick it from the
  boot menu (F12) when needed. `systemd-boot` does not list it (different ESP).
- **Firmware**: `fwupdmgr refresh && fwupdmgr update` for the board.
- **SSH key for GitHub** and **age/GPG keys** only if jupiter will push or read
  secrets, as in [new-host-setup.md](new-host-setup.md), section 7.
- **Backups**: jupiter has no restic job yet; copy the `services.restic.backups`
  block from `hosts/callisto/default.nix` and give it its own bucket and
  `secrets/jupiter.yaml` entries (see section 5).
