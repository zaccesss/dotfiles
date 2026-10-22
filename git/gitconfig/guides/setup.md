# Setup

## 1. Clone

```bash
git clone https://github.com/zaccesss/dotfiles.git ~/dev/github/repos/dotfiles
```

## 2. Fill in your own values

Edit these in the platform file you are about to use, before copying it into place:

| Setting | What to set it to |
| --- | --- |
| `user.name` | Your own name |
| `user.email` | Your commit email |
| `user.signingkey` | The path to your SSH signing public key |
| `gpg.ssh.allowedSignersFile` | The path to your allowed signers list, see [Git's own docs](https://git-scm.com/docs/git-config#Documentation/git-config.txt-gpgsshallowedSignersFile) if you do not have one yet |
| `core.hooksPath` | Where your global hooks live. Remove the line if you have none |
| `credential "https://github.com"` and `gist.github.com` | Remove the `gh auth git-credential` override if you do not use the GitHub CLI, the platform helper works on its own |

> [!NOTE]
> Git expands `~` itself for path-type settings such as `core.hooksPath`, `user.signingkey` and
> `gpg.ssh.allowedSignersFile`, on all three platforms including Windows.

## 3. Copy your platform's file into place

macOS:

```bash
cp ~/dev/github/repos/dotfiles/git/gitconfig/mac/gitconfig ~/.gitconfig
```

Linux:

```bash
sudo apt install libsecret-1-0 libsecret-1-dev  # Debian and Ubuntu, adjust for your distro
cd /usr/share/doc/git/contrib/credential/libsecret && sudo make
cp ~/dev/github/repos/dotfiles/git/gitconfig/linux/gitconfig ~/.gitconfig
```

Windows (Git Bash):

```bash
cp ~/dev/github/repos/dotfiles/git/gitconfig/windows/gitconfig ~/.gitconfig
```

## Verify it worked

```bash
git config --list --show-origin | grep gitconfig
git config user.name
git config user.signingkey
```

> [!TIP]
> Make a throwaway signed commit in a scratch repo and run `git log --show-signature -1` to
> confirm signing verifies, not just that the setting is present.

## Updating after a change to this folder

```bash
cd ~/dev/github/repos/dotfiles/git/gitconfig
git pull
cp <platform>/gitconfig ~/.gitconfig
```

Replace `<platform>` with `mac`, `linux` or `windows`. Re-apply your own values afterwards.

> [!IMPORTANT]
> SSH signing here is `gpg.format = ssh`, not GPG. If you already have a GPG signing setup, pick
> one rather than merging the two.
