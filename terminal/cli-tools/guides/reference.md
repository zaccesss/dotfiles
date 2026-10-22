# Reference

## Why these four tools together

Neovim's Telescope plugin depends on ripgrep to work well. fzf's file listing depends on a
fast recursive file walker, also ripgrep. lazygit and zoxide round out the same fast,
keyboard-first command line workflow. Grouping them in one repo avoids four near-empty repos with
a single file each.

## Values per tool

| Tool | Setting | Value | Why |
| --- | --- | --- | --- |
| ripgrep | `--smart-case` | on | A lowercase query matches case-insensitively, any capital makes it exact |
| ripgrep | `--hidden` | on | Dotfiles matter for this kind of search, `.git/` is excluded by an explicit glob |
| fzf | `FZF_DEFAULT_COMMAND` | `rg --files --hidden --glob '!.git/*'` | Reuses ripgrep's fast walker and its ignore rules |
| fzf | colours | terminal colour names | Follows the terminal's own light or dark palette |
| lazygit | `git.diffRenderers` | `delta` with green, red and reversed changes | Follows the terminal's palette in both modes; falls back to lazygit's own diff view if delta is missing |
| lazygit | `keybinding.universal` | h, j, k, l | vi-style movement through tabs and lists |
