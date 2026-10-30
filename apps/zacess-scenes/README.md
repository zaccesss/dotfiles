# zacess-scenes

[Zacess Scenes](https://github.com/zacesshq/scenes) draws calm animated scenes in the terminal in the Zacess theme `zt` last set and watches a project in any language (a Rust build with [bacon](https://github.com/Canop/bacon)) or the commands typed in a shell: a calm scene while they pass and a storm while one fails, with short sounds. This folder holds my settings and the setup for macOS, Linux and Windows. The scenes and the program itself are described on [zacess.com/scenes](https://zacess.com/scenes/).

| File | Does |
| --- | --- |
| [`scenes.toml`](scenes.toml) | Example settings: a few pass and fail scenes on shuffle every 5 minutes (a scene run on its own too), calm motion, the bells sounds at volume 40 with the typo tone, quiet hours from 22:00 to 07:00 and the background sound off until `a` turns it on |
| [`setup.sh`](setup.sh) | macOS and Linux: the newest release binary into `~/.local/bin` checked against its checksum, bacon with cargo and `scenes.toml` linked to `~/.config/zacess/scenes.toml` |
| [`setup.ps1`](setup.ps1) | Windows: the same into `~\.local\bin` and `%APPDATA%\zacess\scenes.toml`, linked with Developer Mode on and copied otherwise |

There is no theme in `scenes.toml` on purpose: Scenes reads the theme `zt` last set, so a scene always matches the terminal. On Windows `zt` keeps that file under `%LOCALAPPDATA%`, where Scenes does not look, so the PowerShell commands hand the theme over themselves.

## Setup

The bootstraps run the setup in their apps stage. To run it by hand, from the repository root:

```bash
bash apps/zacess-scenes/setup.sh
```

```powershell
& apps\zacess-scenes\setup.ps1
```

Run it again whenever a new release is out: it only downloads when the installed version is older. `--link` (or `-Link`) only links the settings. Edit `scenes.toml` to pick your own scenes and sounds; `zacess-scenes list` shows them all.

## Commands

The shell topics `zacess-scenes` add these on every system:

| Command | Does |
| --- | --- |
| `zs` | A random calm scene, then another every five minutes |
| `zs <scene>` | One scene by name, such as `zs koi-pond` |
| `zs list` | Every scene marked pass, fail or general, plus the sound sets |
| `zs sounds [set] [event]` | Plays one sound set. With no set it plays every set's pass tone in turn |
| `zs config` | Opens `scenes.toml` in the editor |
| `zs new <name>` | Writes a starter Lua scene into `~/.config/zacess/scenes` |
| `zs snap <scene>` | Writes an SVG still of a scene |
| `zs themes` | The themes and which one is active |
| `zsf` | Follows the shells in this tmux session: calm while commands work, a storm when one fails and TYPO for a mistyped command. `ide` opens one beside the shell |
| `zw` | Watches the project here in any language, rerun on each save: bacon for Rust, the project's own check or test command for anything else |
| `zwc` | bacon's Clippy job in a Rust project |
| `zwt` | bacon's test job in a Rust project |
| `zwa` | bacon's check-all job in a Rust project |

The same topics load the follow hook at shell start (`zacess-scenes follow init zsh`, `bash` or `powershell`), so every shell reports its commands to a following scene.

While a scene runs, `n` and `b` switch scenes and `a` turns the background sound on or off, with `[` and `]` for its volume. In the watch and follow modes `m` changes the sound set and the volume goes up with `+` and down with `-`. `q` quits.

## Verify

1. `zacess-scenes --version` shows the newest release.
2. `zacess-scenes config path` points at the linked `scenes.toml`.
3. `zs` shows a scene in the current Zacess theme. After `zt deep-light` the next `zs` shows Deep Contrast Light.
4. `zw` in a project shows ALL GOOD and a breaking change turns it to FAILED (BUILD FAILED with bacon).
5. `zsf` beside a shell in tmux turns to TYPO after a mistyped command and back to ALL GOOD after one that works.
