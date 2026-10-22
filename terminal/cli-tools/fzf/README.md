# fzf

High-contrast colours as terminal colour names, so fzf follows the terminal's light or dark palette, `rg`-backed file listing and the
key-bindings and completion scripts that ship with fzf's own package.

## Install

```sh
brew install fzf
```

## Apply

```sh
mkdir -p ~/.config/fzf
cp fzf/fzf.zsh ~/.config/fzf/fzf.zsh
```

Then source it from your shell rc:

```sh
[[ -f "$HOME/.config/fzf/fzf.zsh" ]] && source "$HOME/.config/fzf/fzf.zsh"
```

The script finds fzf's shell scripts through `brew --prefix fzf` when Homebrew is installed, or
`/usr/share/doc/fzf/examples` on Debian and Ubuntu packages. Confirm the path on your machine
rather than assuming it.

> [!NOTE]
> This is zsh integration, so it does not apply to a native PowerShell session on Windows. Use WSL
> for identical behaviour, a native PowerShell setup needs its own fzf integration.

## Key bindings

| Key | Action |
| --- | --- |
| `Ctrl-T` | Fuzzy-find a file, insert its path at the cursor |
| `Ctrl-R` | Fuzzy-search shell history |
| `Alt-C` | Fuzzy-find a directory and `cd` into it |
| `Ctrl-/` | Toggle the preview window |
