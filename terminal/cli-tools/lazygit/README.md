# lazygit

A high-contrast theme in terminal colour names, `delta` as the diff pager and h/j/k/l navigation for tabs and list items.

## Install

```sh
brew install lazygit git-delta
```

## Apply

The config path differs by OS. Confirm yours with `lazygit --print-config-dir`:

| Platform | Path |
| --- | --- |
| macOS | `~/Library/Application Support/lazygit/config.yml` |
| Linux | `~/.config/lazygit/config.yml` |
| Windows | `%APPDATA%\lazygit\config.yml` |

```sh
mkdir -p ~/Library/Application\ Support/lazygit   # macOS, adjust per the table above
cp lazygit/config.yml ~/Library/Application\ Support/lazygit/config.yml
```

> [!TIP]
> lazygit migrates an older config schema in place on first launch. This file already uses the
> current `git.diffRenderers` structure. If a future release migrates the schema again, launch
> lazygit once and copy the result back here.
