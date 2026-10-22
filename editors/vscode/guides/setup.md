# Setup

## 1. Clone

```bash
git clone https://github.com/zaccesss/dotfiles.git ~/dev/github/repos/dotfiles
```

## 2. Find your settings folder

| Platform | Settings folder |
| --- | --- |
| macOS | `~/Library/Application Support/Code/User/` |
| Linux | `~/.config/Code/User/` |
| Windows | `%APPDATA%\Code\User\` |

## 3. Copy the files into place

```bash
cd ~/dev/github/repos/dotfiles/editors/vscode
cp settings.json "<settings folder>/settings.json"
cp keybindings/<platform>.json "<settings folder>/keybindings.json"
mkdir -p "<settings folder>/snippets"
cp global.code-snippets "<settings folder>/snippets/global.code-snippets"
cp argv.json ~/.vscode/argv.json
```

Replace `<platform>` with `mac` or `windows-linux`. Replace `<settings folder>` with the path from the
table above. `argv.json` always lives at `~/.vscode/argv.json`, unlike `settings.json`.

## 4. Install every extension

`extensions.txt` pins the version each extension was on when it was last updated. Strip the
comments, blank lines and pins before installing so `code` takes whatever is current:

```bash
grep -v '^//' extensions.txt | grep -v '^$' | sed 's/@.*//' | xargs -L 1 code --install-extension
```

## Verify it worked

```bash
code --list-extensions | wc -l
grep -cv '^//\|^$' extensions.txt
```

Compare the two counts. A mismatch usually means one extension failed silently, so run
`code --install-extension <id>` on its own to see the real error.

## Updating after a change to this folder

```bash
cd ~/dev/github/repos/dotfiles/editors/vscode
git pull
```

Then repeat the copy step in section 3.
