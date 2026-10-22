# zoxide

zoxide has no config file of its own, only a shell init hook. Add this to your shell rc:

```sh
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi
```

It is documented here alongside the other tools it is commonly paired with, since there is nothing
else to configure.

## Install

```sh
brew install zoxide
```

## Use

`z <partial-name>` jumps to the best frecency match. `zi` opens an interactive picker when more
than one match is close.
