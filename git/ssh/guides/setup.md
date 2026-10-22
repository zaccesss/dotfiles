# Setup

## 1. Generate your own keys

```bash
ssh-keygen -t ed25519 -C "your-device-name" -f ~/.ssh/id_ed25519
ssh-keygen -t ed25519 -C "your-device-name-signing" -f ~/.ssh/git_sign_ed25519
```

Use a passphrase on both. `ssh-agent` or Keychain integration means you only enter it once per
session, not on every push.

Every machine gets its own pair. Never copy one machine's keys onto another. Use the device name
in the key comment so each key is easy to tell apart on the forge.

To keep the public halves in your own copy of this folder, save them as
`<platform>/id_ed25519.<device-name>.pub` and `<platform>/git_sign_ed25519.<device-name>.pub`
with the device name in lowercase, then delete that platform's `*.placeholder.pub` files. Naming
each file by machine keeps two laptops on the same platform from overwriting each other.

A Linux install inside Windows (WSL) is a separate machine for this purpose: it gets its own pair
in `linux/` and its own `allowed_signers` line, never a copy of the Windows keys. A Linux virtual
machine that shares its host's home folder and SSH agent can use the host's keys instead.

## 2. Register the public keys

- `id_ed25519.pub` as an **authentication key** on every forge you push to.
- `git_sign_ed25519.pub` as a **signing key** on every forge that supports SSH signature
  verification.

## 3. Clone the dotfiles

```bash
git clone https://github.com/zaccesss/dotfiles.git ~/dev/github/repos/dotfiles
```

## 4. Create your allowed signers file

Copy the example and replace the placeholders with your own commit email and the contents of
`~/.ssh/git_sign_ed25519.pub`:

```bash
cp ~/dev/github/repos/dotfiles/git/ssh/allowed_signers.example ~/.ssh/allowed_signers
```

Add one line per signing key, one for each machine you sign commits from, so every machine can
verify commits signed by any other.

## 5. Copy the config into place

```bash
cp ~/dev/github/repos/dotfiles/git/ssh/<platform>/config ~/.ssh/config
chmod 600 ~/.ssh/config ~/.ssh/allowed_signers
chmod 600 ~/.ssh/id_ed25519 ~/.ssh/git_sign_ed25519
chmod 644 ~/.ssh/id_ed25519.pub ~/.ssh/git_sign_ed25519.pub
```

Replace `<platform>` with `mac`, `linux` or `windows`.

## 6. Verify it worked

```bash
ssh -T git@github.com
git config --get gpg.ssh.allowedSignersFile
```

> [!TIP]
> Make a throwaway signed commit and confirm `git log --show-signature -1` returns "Good git
> signature", not just that the settings are present.

## Updating after a change to this folder

```bash
cd ~/dev/github/repos/dotfiles/git/ssh
git pull
cp <platform>/config ~/.ssh/config
```

> [!WARNING]
> Pulling the source repo does not update the active `~/.ssh/config` by itself, the copy step has
> to run again.
