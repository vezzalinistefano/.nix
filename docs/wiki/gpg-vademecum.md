# GPG vademecum

A practical reference for creating, backing up, using and maintaining your PGP key with GnuPG. Written to be re-read after months of not touching it.

`gpg` is installed on every host by `modules/gpg`. On callisto, `modules/gpg-agent` adds the agent and a small window that asks for the passphrase.

## 0. The ideas, in five lines

- A **key** is a pair: the **secret** half stays with you, the **public** half you give to everyone.
- Others use your public key to **encrypt** things only you can read, and to **verify** what you signed.
- Your key is really a small bundle: one **primary key** (your identity, signs things) plus **subkeys** (one for encryption).
- The **fingerprint** (40 hex characters) is the key's real name. The **key ID** is its last 16 characters.
- The **passphrase** protects the secret half on disk. Forget it and the key is dead: there is no reset.

## 1. Create the key (once)

```bash
gpg --full-generate-key
```

Answer the questions like this:

| Question | Answer |
| --- | --- |
| Kind of key | `ECC (sign and encrypt)` (the default, option 9) |
| Elliptic curve | `Curve 25519` (the default) |
| Valid for | `2y` (two years; you extend it later, see section 7) |
| Real name | your name |
| Email | the address you commit and write with |
| Comment | leave empty |
| Passphrase | a long one, stored in your password manager |

Check the result:

```bash
gpg --list-secret-keys --keyid-format=long
```

```
sec   ed25519/AAAA1111BBBB2222 2026-11-15 [SC] [expires: 2028-11-14]
      0123456789ABCDEF0123456789ABCDEFAAAA1111BBBB2222      <- fingerprint
uid                 [ultimate] Your Name <you@example.com>
ssb   cv25519/CCCC3333DDDD4444 2026-11-15 [E] [expires: 2028-11-14]
```

- `sec` is the primary secret key, `[SC]` means it Signs and Certifies.
- `ssb` is the encryption subkey, `[E]`.
- `AAAA1111BBBB2222` after the slash is the key ID you pass to other commands.

In the rest of this page, `KEYID` stands for your key ID or your email address; both work.

## 2. Back it up (right away)

Do this before using the key for anything. Without a backup, a dead disk means a dead key.

```bash
# The secret key, protected by your passphrase
gpg --export-secret-keys --armor KEYID > gpg-secret-KEYID.asc

# The public key
gpg --export --armor KEYID > gpg-public-KEYID.asc

# Who you trust (small, but saves re-answering questions after a restore)
gpg --export-ownertrust > gpg-ownertrust.txt
```

A **revocation certificate** was created automatically with the key. It lets you declare the key dead if it is stolen or you lose the passphrase:

```bash
ls ~/.gnupg/openpgp-revocs.d/     # <fingerprint>.rev
```

Store all four files **off the machine**: an encrypted USB stick kept somewhere safe, plus the password manager for the passphrase. Then delete the exported copies from the working folder:

```bash
shred -u gpg-secret-KEYID.asc      # on Linux
rm gpg-secret-KEYID.asc            # on macOS (the disk is encrypted by FileVault)
```

Never put the secret key or the revocation certificate in a git repo, a cloud folder or an email.

## 3. Put the same key on another machine

One identity on all machines is simpler than one key per machine. Copy `gpg-secret-KEYID.asc` over a safe channel (USB stick, or `scp` between your own machines), then on the new machine:

```bash
gpg --import gpg-secret-KEYID.asc
gpg --import-ownertrust gpg-ownertrust.txt
shred -u gpg-secret-KEYID.asc
```

If you skipped the ownertrust file, mark your own key as trusted by hand:

```bash
gpg --edit-key KEYID
gpg> trust
  5 = I trust ultimately
gpg> quit
```

## 4. Give people your public key

```bash
gpg --export --armor KEYID            # prints it; paste it where needed
```

- **GitHub / GitLab** (so commits show "Verified"): Settings > SSH and GPG keys > New GPG key, paste the block.
- **A person**: send them the `.asc` file, and read them the fingerprint over another channel so they can check it.
- **Keyserver** (optional, public and permanent): `gpg --keyserver hkps://keys.openpgp.org --send-keys KEYID`, then confirm the email it sends you.

## 5. Everyday use

### Sign git commits

```bash
git config --global user.signingkey KEYID
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```

In this repo that belongs in `modules/git/default.nix` instead, so every machine gets it:

```nix
programs.git.settings = {
  user.signingkey = "KEYID";
  commit.gpgsign = true;
  tag.gpgsign = true;
};
```

Check a commit: `git log --show-signature -1`.

### Encrypt and decrypt files

```bash
gpg --encrypt --recipient KEYID file.txt        # -> file.txt.gpg, only KEYID can open it
gpg --decrypt file.txt.gpg > file.txt

gpg --symmetric file.txt                        # password only, no keys involved
```

Add `--armor` for a text file (`.asc`) instead of a binary one, for pasting into email or chat.

### Sign and verify files

```bash
gpg --detach-sign --armor file.tar.gz           # -> file.tar.gz.asc
gpg --verify file.tar.gz.asc file.tar.gz
```

### Someone else's key

```bash
gpg --import their-key.asc
gpg --fingerprint their@email                   # compare with what they tell you
gpg --encrypt --recipient their@email file.txt
```

### Secrets in a repo with sops

`sops` is installed. It can encrypt a YAML or JSON file to your PGP key, so secrets can live in git:

```yaml
# .sops.yaml in the repo root
creation_rules:
  - pgp: "YOUR40CHARACTERFINGERPRINT"
```

```bash
sops secrets.yaml        # opens the decrypted file in $EDITOR, re-encrypts on save
sops -d secrets.yaml     # print decrypted
```

## 6. The agent and the passphrase window

`gpg-agent` remembers the unlocked key so you are not asked on every commit.

- On callisto it is configured in `modules/gpg-agent`: the passphrase is asked again after 1 hour without use, and after 8 hours at the latest.
- Forget the cached passphrase now: `gpgconf --reload gpg-agent`.
- Restart everything: `gpgconf --kill all` (it starts again by itself on the next `gpg` call).
- In a terminal with no desktop (SSH session), run `export GPG_TTY=$(tty)` first so it can ask in the terminal.

## 7. Maintenance

### Extend the expiry (every two years)

An expired key is not lost; you just move the date. Do it on a machine that has the secret key:

```bash
gpg --quick-set-expire FINGERPRINT 2y          # primary key
gpg --quick-set-expire FINGERPRINT 2y '*'      # all subkeys
```

Then redo section 2 (new backup) and section 4 (re-upload the public key to GitHub, GitLab and the keyserver), because the public key changed.

### Change the passphrase

```bash
gpg --change-passphrase KEYID
```

Make a new backup afterwards: old backups still open with the old passphrase.

### Add another email address

```bash
gpg --quick-add-uid KEYID "Your Name <other@example.com>"
```

Then re-publish the public key (section 4).

### Revoke the key (stolen, or passphrase lost)

```bash
gpg --import ~/.gnupg/openpgp-revocs.d/FINGERPRINT.rev    # or from your backup
gpg --keyserver hkps://keys.openpgp.org --send-keys KEYID
```

Remove the key from GitHub and GitLab too, then create a new one (section 1). The revocation file has a `:` placed before its first line as a safety catch; delete that character before importing.

## 8. Cheat sheet

| I want to... | Command |
| --- | --- |
| List my keys | `gpg --list-secret-keys --keyid-format=long` |
| List everyone's keys I hold | `gpg --list-keys` |
| Show a fingerprint | `gpg --fingerprint KEYID` |
| Export my public key | `gpg --export --armor KEYID` |
| Back up my secret key | `gpg --export-secret-keys --armor KEYID > file.asc` |
| Import a key | `gpg --import file.asc` |
| Encrypt for someone | `gpg -e -r THEM file` |
| Decrypt | `gpg -d file.gpg > file` |
| Sign a file | `gpg --detach-sign --armor file` |
| Verify | `gpg --verify file.asc file` |
| Extend expiry | `gpg --quick-set-expire FINGERPRINT 2y` |
| Delete a public key | `gpg --delete-keys KEYID` |
| Delete a secret key | `gpg --delete-secret-keys KEYID` |
| Forget cached passphrase | `gpgconf --reload gpg-agent` |

## 9. When it goes wrong

| Symptom | Fix |
| --- | --- |
| `gpg: signing failed: Inappropriate ioctl for device` | `export GPG_TTY=$(tty)`, or check the agent is running: `gpgconf --launch gpg-agent`. |
| `gpg: signing failed: No pinentry` | The passphrase window program is missing or the agent is stale: `gpgconf --kill gpg-agent` and retry. |
| `error: gpg failed to sign the data` (git) | Test outside git: `echo test \| gpg --clearsign`. The real error shows there. Usually an expired key or a wrong `user.signingkey`. |
| `gpg: decryption failed: No secret key` | The file was encrypted for a key this machine does not have. Import your secret key (section 3). |
| `There is no assurance this key belongs to the named user` | You have not marked the key as trusted. For your own key: section 3, `trust`. For others: check the fingerprint with them first. |
| Key shows `[expired]` | Section 7, extend the expiry. |
| GitHub shows "Unverified" | The commit email must match an email on the key and on your GitHub account; the uploaded public key must be the current one. |
| Everything is confused | `gpgconf --kill all`, then try again. |
