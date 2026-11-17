---
theme: black
transition: slide
---

# jupiter

### Da Proxmox a NixOS, su hardware fisico

<small>17 novembre 2026 · repo `.nix`</small>

---

## TL;DR

- Nuovo host **`jupiter`**: server **fisico** (Giga-byte, Ryzen 5 2600, 15 GiB)
- Oggi è **Proxmox 9** sul NVMe: viene sostituito da NixOS
- Il **Samsung con Windows** resta intatto
- Install via **nixos-anywhere** (kexec locale, l'host non ha internet)

---

## Topologia trovata

| | |
| --- | --- |
| Host | Proxmox VE 9.1.4, hostname `solaris`, `192.168.1.35` |
| Boot | **UEFI**, Secure Boot off |
| NVMe 1TB | Proxmox (`pve-root` 96G + pool 816G) → **wipe** |
| SATA 500G | Samsung, **Windows** di `Vezza`, 244 GB → **intatto** |
| VM | `docker-services` = `arrakis.lan` `.145` → **wipe** |

---

## Non è vezzalini.org

`vezzalini.org` risolve **localmente** a `192.168.8.154`: è un'altra macchina
(openresty, qBittorrent, MAC `84:39:be…`), non l'host Proxmox.

L'host da reinstallare è `192.168.1.35` / MAC `e0:d5:5e…` → **jupiter**. ✅

---

## Cosa cambia nel flake

```nix
mkNixosHost = { hostname, system ? "x86_64-linux", username ? "sv"
              , desktop ? true }:
```

```nix
home-manager.users.${username}.imports =
  [ ./home/common ]
  ++ (if desktop then [ ./home/linux ] else [ ./home/server ]);
```

```nix
"jupiter" = mkNixosHost { hostname = "jupiter"; desktop = false; };
```

callisto non cambia (default `desktop = true`).

---

## `hosts/jupiter/default.nix`

- `networking.hostName = "jupiter"`
- **SSH key-only** (`SWS000135` + `callisto`), firewall aperto
- **avahi** → `jupiter.local`
- NetworkManager (DHCP)
- `zramSwap`, `fstrim`, `tmp` pulita al boot
- GC/optimise settimanali, `trusted-users = [ sv ]`

---

## Disco e boot

`hosts/jupiter/disko.nix` (applicato da nixos-anywhere, **cancella il disco**)

- Device **`/dev/nvme0n1`** (confermato con `lsblk`)
- GPT: **ESP 1G** + root **ext4**
- **Niente LUKS**: il server deve tornare su senza tastiera
- host **UEFI** → **systemd-boot** sull'ESP
- **`/dev/sda` non è mai toccato** (Windows + sua ESP)

---

## `home/server` vs `home/linux`

| Layer | Contenuto |
| --- | --- |
| `home/common` | shell, tmux, nixvim, dev tools (tutti gli host) |
| `home/linux` | Hyprland, waybar, mako, app GUI (desktop) |
| `home/server` | solo `home.stateVersion`, niente desktop |

`desktop = false` evita di installare il mondo grafico sul server.

---

## Accesso e sicurezza

- SSH **key-only**: `SWS000135` e `callisto`
- **sudo chiede la password** di `sv` (`wheelNeedsPassword = true`)
- La password vive in `/etc/shadow` (`passwd`), **mai nel repo**
- SSH resta key-only: la password serve a sudo e alla console fisica
- `nrs jupiter` la chiede; rotazione: `ssh -t sv@jupiter.local passwd`

---

## Installazione: le insidie vere

1. **Nessun IPv4 utile**: l'host ha `192.168.1.35` con gateway inesistente →
   `dhclient -1 vmbr0` per un lease `192.168.8.x`
2. **L'host non ha internet** → `--kexec` con il tarball scaricato dal Mac/callisto
3. **IPv6 link-local** funziona per `ssh`, ma nixos-anywhere usa `ssh://` per
   `nix copy`: serve IPv4
4. **Reconnect dopo kexec**: il lease DHCP per MAC deve tornare lo stesso IP

---

## Installazione

```bash
# sulla macchina che installa
curl -fL -o /tmp/opencode/nixos-kexec.tar.gz \
  https://github.com/nix-community/nixos-images/releases/download/nixos-25.11/nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz

nix run github:nix-community/nixos-anywhere -- \
  --flake .#jupiter \
  --kexec /tmp/opencode/nixos-kexec.tar.gz \
  --generate-hardware-config nixos-generate-config \
    ./hosts/jupiter/hardware-configuration.nix \
  --env-password --target-host root@192.168.8.181
```

---

## Aggiornamenti

- **Automatici**: `release` (CI avanza solo `main` verde), 1×/giorno
- **Manuali**:

```bash
nrs jupiter                   # switch
nrt jupiter                   # attivo, ma il reboot torna indietro
nrs jupiter sv@192.168.8.181  # se .local non risolve
```

Rollback: `sudo nixos-rebuild switch --rollback`

---

## Documentazione e CI

- **Nuovo runbook**: `docs/wiki/jupiter-setup.md`
  - topologia, DHCP/kexec, disco, update, secrets, backup, Windows
- `AGENTS.md` e `README.md` aggiornati
- **CI** ora verifica anche jupiter:
  - eval del `toplevel`
  - `nix build --dry-run` del grafo

---

## Verifiche eseguite

```text
nix eval  .#nixosConfigurations.jupiter...drvPath   ✅
nix build --dry-run .#nixosConfigurations.jupiter   ✅
nix eval  .#nixosConfigurations.callisto...drvPath  ✅
nix flake check                                     ✅
nix fmt                                             ✅
```

---

## Decisioni

- [x] **No LUKS** (reboot headless)
- [x] **Password per sudo** (`passwd`, in `/etc/shadow`), SSH key-only
- [x] **No sops** per ora
- [x] Device **`/dev/nvme0n1`**, systemd-boot/UEFI
- [x] Windows sul **SATA** preservato

---

## Prossimi passi

1. Completare l'install (kexec → disko → reboot)
2. `ssh sv@jupiter.local`, commit dell'hardware scan
3. Commit + push → CI → `release` per l'autoUpgrade
4. DHCP reservation, `fwupdmgr update`
5. Opzionale: sops/age, restic, LUKS/TPM2

---

## File toccati

```text
.github/workflows/ci.yml
AGENTS.md
README.md
docs/wiki/jupiter-setup.md
docs/slides/jupiter.md
flake.nix
home/server/default.nix
hosts/jupiter/default.nix
hosts/jupiter/disko.nix
hosts/jupiter/hardware-configuration.nix
```
