# Managing apps and updates

How a GUI app or CLI tool gets onto the machine with this flake, which pattern to use for a new one, and how to keep everything up to date.
For a fresh machine, start with [new-host-setup.md](new-host-setup.md).

## 1. Pick the install pattern

| Situation | Pattern | Example | Where |
| --- | --- | --- | --- |
| CLI tool in nixpkgs | home-manager package or module | `ripgrep`, `lazygit` | `home/common/default.nix` or `modules/<tool>/default.nix` |
| GUI app in nixpkgs **and** as a Homebrew cask | switchable app (nix or Homebrew per host) | spotify, brave, slack, raycast | `modules/<app>/{app,default,darwin}.nix` |
| GUI app only as a cask in the main Homebrew tap | cask in `homebrew.nix`, config in a module if needed | `linearmouse` | `hosts/common/homebrew.nix` (+ `modules/linearmouse`) |
| GUI app only in a **third-party tap** | small darwin module declaring tap + cask | Spotifast (`crmne/tap`) | `modules/spotifast/darwin.nix` |
| Brew formula not in nixpkgs, or one that must link against Homebrew | `homebrew.brews` | `libpq` | `hosts/common/homebrew.nix` |

Prefer nixpkgs when the package exists and works on `aarch64-darwin`: it is pinned in `flake.lock` and rolls back with the generation.
Prefer a cask when the app self-updates, needs a signed `.app` in `/Applications`, or is missing or broken in nixpkgs.

## 2. Switchable apps (nix or Homebrew)

Each folder holds:

- `app.nix`: `name`, `package` (nixpkgs attribute), `cask`, `default` (`"nix"` or `"homebrew"`).
- `default.nix`: the home-manager half, installs the nixpkgs package when the source is `"nix"`.
- `darwin.nix`: the nix-darwin half, declares `apps.<name>.source` and adds the cask when it is `"homebrew"`.

All three come from `modules/lib/mk-switchable-app.nix`. Override per host in `hosts/<HOSTNAME>/default.nix`:

```nix
apps.spotify.source = "nix";   # or "homebrew"
```

To add one: copy an existing folder, edit `app.nix`, import `darwin.nix` in `hosts/common/default.nix` and `default.nix` in `home/common/default.nix`, `git add` the folder, then `drb`.

## 3. Casks from a third-party tap

When the app is only published through its author's tap, declare the tap and the fully qualified cask together in one module, so removing the module removes both:

```nix
# modules/spotifast/darwin.nix
_: {
  homebrew = {
    taps = [ "crmne/tap" ];
    casks = [ "crmne/tap/spotifast" ];
  };
}
```

Then import it in `hosts/common/default.nix` (all hosts) or in one `hosts/<HOSTNAME>/default.nix` (that host only).
nix-darwin merges `homebrew.taps` and `homebrew.casks` lists from every module, so `hosts/common/homebrew.nix` does not need to change.

Check the result without building:

```bash
nix eval .#darwinConfigurations.$(scutil --get LocalHostName).config.homebrew.casks --apply 'map (c: c.name)'
```

> Some upstream repos also ship a `flake.nix` with Darwin packages (Spotifast does). Using it as a flake input builds the app from source on every update and skips the signed `.app` from the cask, so the cask is the default choice here.

### Spotifast notes

- Native Rust Spotify client, no browser engine. Playback needs Spotify **Premium**.
- First launch: create an app in the [Spotify developer dashboard](https://developer.spotify.com/dashboard) with redirect URI `http://127.0.0.1:8989/login` and **Web API** ticked, then paste the Client ID into Spotifast.
- It is installed next to the regular `spotify` app, not instead of it. It appears as a Spotify Connect device named **Spotifast**.

## 4. Updating

Two independent sources of versions:

| What | Pinned by | Update with |
| --- | --- | --- |
| nixpkgs, home-manager, nixvim, stylix, nix-darwin, other inputs | `flake.lock` | `nix flake update` (all) or `nix flake update <input>` |
| Homebrew casks and brews | Homebrew itself | `drs` (`onActivation.autoUpdate` and `upgrade` are `true`), or `brew upgrade --cask` |

Routine:

```bash
cd ~/.nix
nix flake update      # or: nix flake update nixpkgs
drb                   # build only, catches evaluation and build errors
drs                   # switch
git commit flake.lock -m "chore: update flake inputs"
```

Run `nix flake update` as your user, not with `sudo`, or `flake.lock` ends up owned by root.
On recent Nix, positional arguments to `nix flake update` are input names. Point at another flake with `--flake <path>`.

### When an update breaks the build

Input updates can remove or rename options. Example: after a nixvim bump, `plugins.lsp.servers.schemastore` no longer exists and `modules/nixvim/plugins/lsp.nix` fails to evaluate.

1. Read the option path in the error and check the input's changelog or option search for the new name.
2. To unblock immediately, restore the previous pins: `git checkout flake.lock && drs`.
3. Or keep the new pins for everything except the broken input: `git checkout flake.lock`, then `nix flake update <other inputs>`.
4. Already switched to a bad generation: `sudo darwin-rebuild --rollback`.

## 5. Troubleshooting audio (Spotify and Bluetooth headphones)

Not nix-related, kept here because it comes up with the music apps.

| Symptom | Check |
| --- | --- |
| No sound, app shows paused | Spotify Connect may be playing on another device. Pick **This computer** in the device menu. |
| Low quality or silence with AirPods | AirPods also selected as **input** switch to the call profile. Set input to the built-in microphone (System Settings > Sound > Input). |
| Two devices with the same AirPods name | Make sure the pair you are wearing is the one selected in Control Center > Sound. |
| Output changed while playing | Quit and reopen the app (⌘Q). |

Inspect from the terminal:

```bash
system_profiler SPAudioDataType | grep -E "Default|Transport"
osascript -e 'get volume settings'
osascript -e 'tell application "Spotify" to get player state'
```
