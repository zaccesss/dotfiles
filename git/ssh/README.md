# ssh

> SSH client config for macOS, Linux and Windows: per-host key selection for GitHub, agent settings
> and an allowed signers example for verifying signed commits.

A dedicated auth key per host, a separate signing key and an `allowed_signers` list that covers
every machine you sign from. This folder holds the client-side config and never a private key, so a
new machine gets the correct setup in a few steps.

## What's here

- **`<platform>/config`** - `Host` blocks pointing `github.com` and `gist.github.com` at a
  dedicated auth key with `IdentitiesOnly yes`, so SSH never falls back to offering the wrong key
  first. `AddKeysToAgent yes` means a passphrase is only asked for once per session.
- **`<platform>/*.placeholder.pub`** - where each machine's public keys go. Every placeholder
  carries the `ssh-keygen` command for that platform and the filename to use:
  `<platform>/<key>.<device-name>.pub`, one file per machine, since several machines can share a
  platform folder. Public keys only, never the private half.
- **[`allowed_signers.example`](allowed_signers.example)** - the format of the file Git reads to
  verify SSH commit signatures locally, with placeholders for your own email and public key. See
  [guides/reference.md](guides/reference.md).
- **[`.gitignore`](../../.gitignore)** - its `git/ssh/` section blocks any filename shaped like a private key, as a backstop.

## The one per-platform difference

`UseKeychain yes` is an Apple-only OpenSSH directive that stores key passphrases in the macOS
Keychain, so it only appears in `mac/config`. OpenSSH on Linux and Windows rejects that line as an
unknown option, so `linux/` and `windows/` drop it and rely on `ssh-agent` alone.

> [!CAUTION]
> None of this ships a private key. Nothing here should ever hold one. `.gitignore` blocks
> private-key-shaped filenames and CI fails on any private key header in the tree.

## Setup

```bash
git clone https://github.com/zaccesss/dotfiles.git ~/dev/github/repos/dotfiles
cp ~/dev/github/repos/dotfiles/git/ssh/<platform>/config ~/.ssh/config
chmod 600 ~/.ssh/config
```

Replace `<platform>` with `mac`, `linux` or `windows`. See [guides/setup.md](guides/setup.md) for
generating your own key pairs and setting up `allowed_signers`.

## Structure

| Path | Contents |
| --- | --- |
| [`mac/`](mac/) | Config with `UseKeychain`, public key placeholders |
| [`linux/`](linux/) | Config without `UseKeychain`, public key placeholders |
| [`windows/`](windows/) | Config without `UseKeychain`, public key placeholders |
| [`allowed_signers.example`](allowed_signers.example) | Allowed signers format with placeholders |
| [`guides/`](guides/) | Key generation walkthrough and reference |
