# gitconfig

> Git config for macOS, Linux and Windows: SSH commit and tag signing, per-platform credential
> helpers, GitHub CLI auth and global hook wiring.

Identity, SSH commit signing, credential helpers and hook wiring are set once here rather than
reconfigured from memory on every fresh machine.

## What's here

- **Identity** - `user.name` and `user.email`, set to placeholders you replace with your own.
- **Commit and tag signing** - SSH-format signing (`gpg.format = ssh`) using a dedicated signing
  key, separate from the key used for authentication. `allowedSignersFile` points at the list of
  keys Git trusts for verifying signatures locally.
- **Hook wiring** - `core.hooksPath` points at a global hooks directory such as the one installed
  from [git-hooks](../git-hooks), so every repo runs the same hooks
  without per-repo setup.
- **Credential helper** - the platform's native credential store, plus a `gh auth git-credential`
  override for `github.com` and `gist.github.com` so HTTPS operations authenticate through the
  GitHub CLI's token instead of a separate stored password.
- **Git LFS filters** - the standard `clean`, `smudge` and `process` wiring.
- **Fetch and pull** - `fetch.prune` drops branches deleted on the remote and `pull.ff = only`
  stops `git pull` from writing a merge commit.

See [guides/reference.md](guides/reference.md) for what every section does and why.

## The per-platform differences

Everything is identical across macOS, Linux and Windows except the credential helper:
`osxkeychain` on macOS, `libsecret` on Linux (needs `libsecret` or `gnome-keyring` installed) and
`manager` on Windows (bundled with Git for Windows). Windows also sets `core.sshCommand` to the
Windows OpenSSH client, so Git uses the same SSH agent as `ssh`. That is why `mac/`, `linux/` and
`windows/` each carry their own copy rather than one file with a conditional.

## Setup

> [!IMPORTANT]
> Replace `user.name`, `user.email` and `user.signingkey` with your own values before installing.
> The files ship with placeholders, see [guides/setup.md](guides/setup.md).

```bash
git clone https://github.com/zaccesss/dotfiles.git ~/dev/github/repos/dotfiles
cp ~/dev/github/repos/dotfiles/git/gitconfig/<platform>/gitconfig ~/.gitconfig
```

Replace `<platform>` with `mac`, `linux` or `windows`.

## Structure

| Path | Contents |
| --- | --- |
| [`mac/`](mac/) | The full config with the macOS credential helper |
| [`linux/`](linux/) | The full config with the Linux credential helper |
| [`windows/`](windows/) | The full config with the Windows credential helper |
| [`guides/`](guides/) | Install walkthrough and the section-by-section reference |
