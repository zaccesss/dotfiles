# zacess-games

[Zacess Games](https://github.com/zacesshq/games) is fourteen small original games for the terminal, drawn in the Zacess theme `zt` last set. Every colour keeps the theme's contrast floor, nothing flashes and each game has soft sound effects and calm music made by the program itself. This folder holds the setup for macOS, Linux and Windows.

| File | Does |
| --- | --- |
| [`setup.sh`](setup.sh) | macOS and Linux: the newest release binary into `~/.local/bin`, checked against its published checksum |
| [`setup.ps1`](setup.ps1) | Windows: the same into `~\.local\bin` |

There is no settings file here: the games have none to read. The sound levels, best scores and progress are remembered by the games themselves in `~/.local/state/zacess-games/scores.txt` (`%LOCALAPPDATA%\zacess-games` on Windows). The theme comes from the one `zt` last set, so a game always matches the terminal. On Windows `zt` keeps that file under `%LOCALAPPDATA%`, where the games do not look, so the PowerShell `zg` hands the theme over itself.

## Setup

The bootstraps run the setup in their apps stage. To run it by hand, from the repository root:

```bash
bash apps/zacess-games/setup.sh
```

```powershell
& apps\zacess-games\setup.ps1
```

Run it again whenever a new release is out: it only downloads when the installed version is older. A download that does not match its checksum is never installed.

## Commands

The shell topics `zacess-games` add these on every system, with Tab completion of the fourteen game names and the subcommands:

| Command | Does |
| --- | --- |
| `zg` | The menu |
| `zg <game>` | One game by name, such as `zg trace`. A short start is enough, such as `zg stack` |
| `zg list` | Every game and its best score |
| `zg sounds [game]` | Plays every effect, then each game's music, so sound can be checked outside a game |
| `zg snap [game]` | SVG stills of one game or all of them |
| `zg --help` | Every option, such as `--reduced-motion`, `--volume` and `--music-volume` |

`zacess-game` is the same as `zg`. The games are stackline, merge-gates, termle, signal, trace, drift, rooms, relay, through-ball, slipstream, array-guard, heatsink, touch-typing and learn-to-code.

## Keys

In most games `Space` pauses, `?` shows how to play and `Q` or `Esc` goes back to the menu. In the three typing games (Heatsink, Touch Typing and Learn to Code) every key types, so `Esc` pauses and `F1` shows how to play. `Ctrl+C` always leaves.

Effects start at volume 35 and music at 20, out of 100:

| Key | Does |
| --- | --- |
| `+` and `-` | Effects volume up and down in steps of 10 |
| `]` and `[` | Music volume up and down in steps of 10 |
| `0` | Mute everything; press it again to bring everything back |

The right end of every status bar shows both levels, such as `FX 35% · Music 20%`. Changes are remembered for the next run. In the typing games the sound keys work while paused with `Esc`. Every key of every game is on the [controls sheet](https://github.com/zacesshq/games/blob/main/docs/controls.md).

## Verify

1. `zacess-games --version` shows the newest release.
2. `zg` shows the menu in the current Zacess theme with `FX 35% · Music 20%` at the top right. After `zt deep-light` the next `zg` shows Deep Contrast Light.
3. `zg sounds` plays every effect and then each game's music.
4. `zg st` then `Tab` completes to `zg stackline`.
