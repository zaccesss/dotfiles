# ripgrep

Smart case, hidden files included, `.git/` excluded and colours tuned for readability.

## Install

```sh
brew install ripgrep       # macOS
sudo apt install ripgrep   # Debian and Ubuntu
```

## Apply

`rg` does not read `ripgreprc` automatically. It only reads the file the `RIPGREP_CONFIG_PATH`
environment variable points at:

```sh
cp ripgrep/ripgreprc ~/.ripgreprc
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"   # add this line to your shell rc
```
