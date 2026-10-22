# Setup

## Install tmux

```sh
brew install tmux        # macOS
sudo apt install tmux    # Debian and Ubuntu, other distros use their own package manager
```

Windows: install WSL first, then `sudo apt install tmux` inside it.

## Install the config

```sh
cp tmux.conf ~/.tmux.conf
```

## Install TPM and the plugins

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

> [!TIP]
> Plugins install through TPM as a separate step from copying the config. Nothing plugin-related
> works until it runs.

Then, inside a tmux session, press the prefix (`Ctrl-b`) followed by `I` (capital i) to install
every plugin the config lists. From a plain shell:

```sh
~/.tmux/plugins/tpm/scripts/install_plugins.sh
```

## Verify it worked

```sh
tmux new-session -d -s verify
tmux list-sessions
tmux kill-session -t verify
```

A session listed with no error means the config parsed cleanly.

## Key bindings

See [reference.md](reference.md#key-bindings).
