# Setting up a new Mac (Apple Silicon) with Nix, nix-darwin and home-manager

This guide takes a fresh Apple Silicon Mac from nothing to a fully applied copy of this flake.
It covers Nix as a package manager, nix-darwin (system), home-manager (user), Homebrew (casks and brews declared in nix) and the per-host wiring in the repo.

> **Scope:** `aarch64-darwin` only. Hosts are named after the machine hostname (for example `SWS000154`, `SWS000135`).
> Verify the commands against the current upstream docs if something fails, since installers change.

## 0. Overview

| Layer | Tool | Where it lives in the repo |
| --- | --- | --- |
| Package manager and daemon | Nix (official installer) | not in the repo, installed once by hand |
| macOS system settings | nix-darwin | `hosts/common/`, `hosts/<HOSTNAME>/` |
| User packages and dotfiles | home-manager (as a nix-darwin module) | `home/common/`, `modules/*` |
| GUI apps and brews not in nixpkgs | Homebrew, managed by nix-darwin | `hosts/common/homebrew.nix` |

`flake.nix` builds every host through `mkDarwinHost`. All hosts share `hosts/common` and `home/common`, and `hosts/<HOSTNAME>/default.nix` only holds machine-specific overrides (today just `networking.hostName`).

## 1. Prerequisites on the new Mac

1. Finish macOS setup and sign in to your user. The username must match the one in the flake (`stefanovezzalini`), because `home/common` and `hosts/common` hardcode `/Users/stefanovezzalini`. Otherwise see [Different username](#different-username).
2. Set the hostname. It decides which flake output `darwin-rebuild` picks:
   ```bash
   sudo scutil --set HostName   SWS000135
   sudo scutil --set LocalHostName SWS000135
   sudo scutil --set ComputerName  SWS000135
   scutil --get LocalHostName   # check
   ```
3. Install the Xcode Command Line Tools (gives you `git`, `make`, a compiler):
   ```bash
   xcode-select --install
   ```
4. Create an SSH key and add it to GitHub. The repo remote is `git@github.com:vezzalinistefano/.nix.git`, and `modules/git` rewrites `https://github.com/` to SSH.
   ```bash
   ssh-keygen -t ed25519 -C "s.vezzalini@iungo.it"
   cat ~/.ssh/id_ed25519.pub   # add it at https://github.com/settings/keys
   ssh -T git@github.com
   ```
5. Optional: if you have not done so already, grant your terminal **Full Disk Access** (System Settings > Privacy & Security). It avoids permission prompts during activation.

## 2. Install Nix (the package manager)

Use the **official** installer in multi-user (daemon) mode. This flake sets `nix.enable = true`, so nix-darwin manages the Nix installation and daemon. **Do not use the Determinate Systems installer** here: it manages Nix itself and conflicts with `nix.enable = true`.

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Open a **new terminal** afterwards so the profile is sourced, then check:

```bash
nix --version
```

Notes:

- The installer creates an APFS volume mounted at `/nix` and the `nixbld` build users, and adds hooks to `/etc/zshrc`, `/etc/bashrc` and `/etc/nix/nix.conf`.
- Flakes are not enabled yet. They are enabled system-wide by this config (`nix.settings.experimental-features`) once it has been applied. Until then, pass `--extra-experimental-features 'nix-command flakes'` (shown in step 5).

## 3. Install Homebrew

nix-darwin only configures Homebrew, it does not install it. `hosts/common/homebrew.nix` has `homebrew.enable = true`, so install brew first:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Note: `homebrew.onActivation.cleanup` is `"none"`, so packages not declared in `homebrew.nix` are left alone. `"zap"` and `"uninstall"` are broken with Homebrew 7, which removed the `brew bundle --cleanup` flag that this nix-darwin revision calls. Revisit after updating the `darwin` input.

## 4. Get the repo

The shell aliases (`drs`, `drb`, `drc`, `dru`, `drf` in `modules/zsh`) point to `/private/etc/nix-darwin`. Clone to `~/.nix` and symlink that path so both work:

```bash
git clone git@github.com:vezzalinistefano/.nix.git ~/.nix
sudo ln -s ~/.nix /private/etc/nix-darwin
ls -l /etc/nix-darwin   # -> /Users/<you>/.nix
```

## 5. Add the host to the flake

Skip this section when the host already exists in `flake.nix`. It is needed once per new machine.

1. Create the host directory:
   ```bash
   mkdir hosts/<HOSTNAME>
   ```
   `hosts/<HOSTNAME>/default.nix`:
   ```nix
   { ... }:
   {
     imports = [ ../common ];

     networking.hostName = "<HOSTNAME>";
   }
   ```
2. Register it in `flake.nix` under `darwinConfigurations`:
   ```nix
   "<HOSTNAME>" = mkDarwinHost { hostname = "<HOSTNAME>"; };
   ```
   `mkDarwinHost` defaults to `system = "aarch64-darwin"` and `username = "stefanovezzalini"`. Override them in the call if needed.
3. **`git add` the new files.** Flakes only see files tracked by git, so an untracked `hosts/<HOSTNAME>/` fails with "path does not exist".
   ```bash
   git add hosts/<HOSTNAME> flake.nix
   ```
4. Machine-specific settings that differ per host (extra packages, a different `homebrew.nix`, extra imports) go in `hosts/<HOSTNAME>/default.nix`. Anything shared goes in `hosts/common` or `home/common`.

### Different username

`users.users.stefanovezzalini`, `system.primaryUser`, `GOPATH` and `home.homeDirectory` are hardcoded for `stefanovezzalini`. A different username means parameterising those in `hosts/common/default.nix`, `home/common/default.nix` and `mkDarwinHost`, which is not done today.

## 6. First build and activation

The first activation has to bootstrap nix-darwin, because `darwin-rebuild` does not exist yet.

1. **Move the files nix-darwin wants to own** out of the way. Otherwise activation aborts with `Unexpected files in /etc, aborting activation`:
   ```bash
   sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin
   sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
   sudo mv /etc/zshrc  /etc/zshrc.before-nix-darwin
   ```
   Only move the files the error message lists. The installer's `/etc/nix/nix.conf` is replaced by one generated from the flake.
2. Build and switch, from the repo:
   ```bash
   cd ~/.nix
   sudo nix --extra-experimental-features 'nix-command flakes' \
     run nix-darwin/master#darwin-rebuild -- switch --flake .#<HOSTNAME>
   ```
   This evaluates the flake, downloads from cache.nixos.org (and builds anything missing), runs Homebrew, applies home-manager, and sets the hostname. The first run takes a while.
3. If home-manager reports an existing file, it is renamed with the `.backup` suffix (`home-manager.backupFileExtension = "backup"`). A stale `*.backup` blocks the next run, so delete it.
4. Open a **new terminal**. `darwin-rebuild` is now on the PATH and the aliases are loaded.

From now on:

| Alias | Command | Purpose |
| --- | --- | --- |
| `drs` | `sudo darwin-rebuild switch --flake /private/etc/nix-darwin` | rebuild and switch |
| `drb` | `darwin-rebuild build --flake ...` | build without switching |
| `drc` | `nix flake check ...` | check the flake |
| `dru` | `nix flake update` + switch | update inputs and rebuild |
| `drf` | `nixfmt ...` | format nix files |

With no `#<HOSTNAME>` given, `darwin-rebuild` picks the flake output matching the machine hostname. That is why step 1.2 matters.

## 6b. Choosing nix or Homebrew per app

GUI apps such as Spotify, Brave, Slack and Raycast can come from nixpkgs or from a Homebrew cask. The default is in `modules/<app>/app.nix`. Override it for this machine in `hosts/<HOSTNAME>/default.nix`, for example `apps.spotify.source = "nix";`, then `drs`. See [managing-apps.md](managing-apps.md) for the patterns, including casks from third-party taps.

## 7. Manual post-install steps

Things nix cannot do for you:

- **TouchID for sudo** is configured by `security.pam.services.sudo_local`, so it works after the first switch. Test it in a new terminal with `sudo -v`.
- **skhd** needs Accessibility permission: System Settings > Privacy & Security > Accessibility > allow `skhd` (prompted on first launch).
- **Remote Login (sshd)** is enabled by `modules/openssh`, key-only. Keys are read only from `users.users.<name>.openssh.authorizedKeys.keys` in that module, never from `~/.ssh/authorized_keys`. Add the public keys of the machines that should log in here, then `drs`. The list is empty today, so nobody can log in.
- **GPG**: import or generate your key (`gpg --import` / `gpg --full-generate-key`). Signing and sops/age secrets need it.
- **age / sops**: copy your age key to the new Mac (for example `~/.config/sops/age/keys.txt`) from a safe channel. No secrets are stored in the repo.
- **GUI apps**: log in to Slack, Spotify, Obsidian, Brave, Telegram and so on. Raycast and Ghostty settings are managed by their modules where configured.
- **Cloud CLIs**: `gcloud auth login`, `glab auth login`, `kubectl` contexts.
- **Spotlight/Launchpad**: apps installed through home-manager end up under `~/Applications/Home Manager Apps` or `/Applications/Nix Apps`. Raycast indexes them, Spotlight may need a moment.

## 8. Verify

```bash
darwin-rebuild --list-generations   # a generation exists
hostname                            # matches <HOSTNAME>
which nvim git                      # resolved from /run/current-system or ~/.nix-profile
nix flake check /private/etc/nix-darwin
```

If the system and `home-manager` activation succeeded, `nixvim`, `tmux`, `ghostty`, `zsh` + `starship` and the dev tools from `home/common/default.nix` are available in a fresh shell.

## 9. Day-to-day workflow

```bash
cd ~/.nix
$EDITOR modules/<tool>/default.nix   # edit, or add a module and import it in home/common/default.nix
git add -A                           # new files must be tracked for flakes
drb                                  # build only, catches errors
drs                                  # switch
git commit -am "feat: ..." && git push
```

Rollback: `sudo darwin-rebuild switch --rollback`, or pick an older generation from `darwin-rebuild --list-generations`.

Garbage collection (weekly, older than 1 week) and store optimisation are automatic (`nix.gc`, `nix.optimise`). To collect manually: `sudo nix-collect-garbage -d`.

## 10. Troubleshooting

| Symptom | Fix |
| --- | --- |
| `Unexpected files in /etc, aborting activation` | Move the listed files to `*.before-nix-darwin` (step 6.1) and re-run. |
| `error: path '.../hosts/<HOSTNAME>' does not exist` | New files are not tracked by git. `git add` them. |
| `error: flake ... does not provide attribute darwinConfigurations.<name>` | The hostname differs from the flake key. Check `scutil --get LocalHostName`, or pass `.#<HOSTNAME>` explicitly. |
| `experimental Nix feature 'nix-command' is disabled` | Pass `--extra-experimental-features 'nix-command flakes'` for the first run only. |
| `nix: command not found` after install | Open a new terminal, or `source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh`. |
| `Existing file ... is in the way` (home-manager) | Remove the stale `<file>.backup`, or move the existing file aside. |
| Build killed or out of memory | Close apps and retry. `modules/checkov` is disabled for this reason (see `home/common/default.nix`). |
| Homebrew step fails: `brew: command not found` | Install Homebrew (step 3), then open a new terminal. |
| `sudo` has no TouchID | Use a new terminal, since it only applies to sessions started after the switch. In tmux it needs `pam-reattach` (configured). |

## 11. Uninstalling (reference)

nix-darwin: `sudo nix --extra-experimental-features 'nix-command flakes' run nix-darwin#darwin-uninstaller`. Nix itself: follow the "Uninstalling" section of the official Nix manual for macOS (it removes the `/nix` volume, the `nixbld` users and the shell hooks).
