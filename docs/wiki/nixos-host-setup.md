# Installing and updating a NixOS host remotely (callisto)

callisto is a ThinkPad T480 (`x86_64-linux`) running NixOS with Hyprland. It is installed and updated from one of the Macs over SSH: the Mac evaluates the flake and pushes, callisto builds its own system.

> Verify the commands against the current upstream docs if something fails, since nixos-anywhere and nixos-rebuild change.

## 0. Where things live

| What | Where |
| --- | --- |
| System configuration | `hosts/callisto/default.nix` |
| Disk layout (LUKS + ext4) | `hosts/callisto/disko.nix` |
| Hardware scan | `hosts/callisto/hardware-configuration.nix` (generated at install) |
| User configuration shared with the Macs | `home/common/` |
| Linux desktop user configuration | `home/linux/`, `modules/hyprland`, `modules/waybar`, `modules/vicinae`, `modules/mako`, `modules/hyprlock` |

`flake.nix` builds it through `mkNixosHost` (user `sv`). The work tooling in `home/work` and the macOS parts in `home/darwin` are not imported.

## 1. Install (once, wipes the disk)

The install uses [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) with [disko](https://github.com/nix-community/disko).

On callisto:

1. Boot the NixOS minimal installer ISO from a USB stick (F12 for the boot menu; Secure Boot off in the BIOS).
2. Get on the network. Ethernet works by itself; for Wi-Fi run `nmtui`.
3. Set a password for the installer's `nixos` user and note the IP and the disk name:
   ```bash
   passwd
   ip -4 addr
   lsblk
   ```
4. If the system disk is not `/dev/nvme0n1`, change `device` in `hosts/callisto/disko.nix` on the Mac. **Everything on that disk is erased.**

On the Mac, from the repo:

```bash
cd ~/.nix
# Disk passphrase, asked again at every boot. No trailing newline.
echo -n 'your disk passphrase' > /tmp/luks.key

SSHPASS='<installer password>' nix run github:nix-community/nixos-anywhere -- \
  --flake .#callisto \
  --build-on remote \
  --generate-hardware-config nixos-generate-config ./hosts/callisto/hardware-configuration.nix \
  --disk-encryption-keys /tmp/luks.key /tmp/luks.key \
  --env-password \
  --target-host nixos@<IP>

rm /tmp/luks.key
```

`--build-on remote` is needed because the Mac cannot build Linux packages. The machine reboots into the installed system when it finishes.

### Without a USB stick

nixos-anywhere can also take over a machine that already runs Linux (this is how callisto was first installed, from Arch): it loads the NixOS installer into RAM over SSH and carries on from there. The machine needs SSH access with your key, more than 1 GB of RAM, and root rights without a password prompt. For the last one, on the machine:

```bash
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/99-nixos-install
```

Then run the same command from the Mac without `SSHPASS` and `--env-password`, with `--target-host <user>@<IP>`. If the network is Wi-Fi only, use the USB installer instead: the takeover does not carry the Wi-Fi connection over.

Afterwards:

1. Type the disk passphrase at boot. Hyprland starts as `sv` without a second login.
2. The password of `sv` (for `sudo` and the lock screen) is the one stored, encrypted, in `secrets/callisto.yaml`. Set it on the Mac **before** installing with `scripts/set-user-password.sh callisto sv` and commit the file. It is only applied when the account is created; later, change it on callisto with `passwd`.

   A reinstall gives callisto a new SSH host key, which is also the key it decrypts secrets with. Before reinstalling, pass the old host key to nixos-anywhere with `--extra-files`, or after it update the `age_callisto` line in `.sops.yaml` (`ssh-keyscan callisto.local | ssh-to-age`), run `sops updatekeys secrets/callisto.yaml` and deploy again.
3. On the Mac, commit the generated `hosts/callisto/hardware-configuration.nix`.
4. The SSH host key changed with the install. If SSH complains: `ssh-keygen -R <IP>`.

## 2. Update (day to day)

On the Mac, after editing the flake:

```bash
nrs callisto          # build on callisto and switch
nrt callisto          # build and activate, but a reboot goes back to the previous system
```

Both are defined in `modules/zsh` and run:

```bash
nixos-rebuild switch --no-reexec \
  --flake /private/etc/nix-darwin#callisto \
  --target-host sv@callisto.local --build-host sv@callisto.local \
  --sudo --ask-sudo-password
```

- They ask for the sudo password of `sv` on callisto.
- `callisto.local` is announced by avahi. If it does not resolve, pass the destination: `nrs callisto sv@<IP>`.
- New files must be `git add`ed first, as for the Macs.
- Only machines whose public key is listed in `users.users.sv.openssh.authorizedKeys.keys` (`hosts/callisto/default.nix`) can log in. Add the other Mac's `~/.ssh/id_ed25519.pub` there to deploy from it.

Rollback: pick an older generation in the boot menu, or on callisto `sudo nixos-rebuild switch --rollback`.

## 3. Desktop keys

Super is the modifier (`modules/hyprland/hyprland.lua`).

| Keys | Action |
| --- | --- |
| Super+Return | Ghostty on herdr (Super+Shift+Return: plain Ghostty) |
| Super+Space | launcher (vicinae: apps, calculator, emoji, windows) |
| Super+Shift+V | clipboard history |
| Super+B | LibreWolf |
| Super+Q | close window |
| Super+h/j/k/l | focus (with Shift: move, with Ctrl: resize) |
| Super+1..0 | workspace (with Shift: send window there) |
| Super+F / Super+M | fullscreen / maximise |
| Super+V | toggle floating |
| Super+S | scratchpad (with Shift: send window there) |
| Super+Escape | lock |
| Super+Shift+E | log out |
| Print / Shift+Print | screenshot of a region to the clipboard / of the screen to `~/Pictures` |
| Alt+Shift | switch keyboard layout (Italian, US International) |

## 4. Manual steps after the install

- **Wi-Fi**: `nmtui`.
- **Bluetooth**: `bluetoothctl`.
- **Firmware**: `fwupdmgr refresh && fwupdmgr update`.
- **SSH key for GitHub**, **age/sops keys**: as in [new-host-setup.md](new-host-setup.md), section 7.
- **GPG**: see [gpg-vademecum.md](gpg-vademecum.md).
- **LibreWolf**: Vimium is installed by policy; allow it in private windows from the add-ons page if you want it there.
- **herdr plugins**: installed by hand, see `modules/herdr/default.nix`.
