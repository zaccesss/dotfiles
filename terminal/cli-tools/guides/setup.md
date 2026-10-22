# Setup

## Install everything

```sh
brew install ripgrep fzf lazygit zoxide git-delta        # macOS
sudo apt install ripgrep fzf lazygit zoxide git-delta    # Debian and Ubuntu, package names vary by distro
winget install BurntSushi.ripgrep.MSVC junegunn.fzf JesseDuffield.lazygit ajeetdsouza.zoxide dandavison.delta   # Windows, native binaries
```

## Apply each config

```sh
cp ripgrep/ripgreprc ~/.ripgreprc
mkdir -p ~/.config/fzf && cp fzf/fzf.zsh ~/.config/fzf/fzf.zsh
mkdir -p ~/Library/Application\ Support/lazygit && cp lazygit/config.yml ~/Library/Application\ Support/lazygit/config.yml   # macOS, see lazygit/README.md for the Linux and Windows paths
```

zoxide needs no file, only the shell hook in [`zoxide/README.md`](../zoxide/README.md).

## Wire the shell rc

Add to your `.zshrc`:

```sh
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
[[ -f "$HOME/.config/fzf/fzf.zsh" ]] && source "$HOME/.config/fzf/fzf.zsh"
alias lg="lazygit"
```

## Verify each tool

```sh
rg --version && echo "ripgrep OK"
echo $FZF_DEFAULT_COMMAND    # should print an rg command
lazygit --print-config-dir   # confirms which path lazygit reads on this OS
```

## Key bindings

`+` joins keys pressed together and a space separates keys pressed one after another.

| Tool | Keys | Action |
| --- | --- | --- |
| fzf | `Ctrl+T` | Fuzzy-find a file, insert its path at the cursor |
| fzf | `Ctrl+R` | Fuzzy-search shell history |
| fzf | `Alt+C` | Fuzzy-find a directory and `cd` into it |
| fzf | `Ctrl+/` | Toggle the preview window |
| lazygit | `h` `j` `k` `l` | Switch tabs (h and l) and move up or down a list (j and k) |
| lazygit | `c` | Commit the staged changes |
| lazygit | `r` (in the commits panel) | Reset options for the selected commit |
