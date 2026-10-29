# zacess-scenes

[Zacess Scenes](https://github.com/zacesshq/scenes) draws calm animated scenes in the terminal in the Zacess theme `zt` last set and watches a Rust build with [bacon](https://github.com/Canop/bacon): a calm scene while it passes and a storm while it fails, with short sounds. This folder holds example settings and the setup for macOS, Linux and Windows. Every scene is shown on [zacess.com/scenes](https://zacess.com/scenes/).

| File | Does |
| --- | --- |
| [`scenes.toml`](scenes.toml) | Example settings: a few pass and fail scenes on shuffle every 10 minutes, calm motion, the bells sounds at volume 40 and quiet hours from 22:00 to 07:00 |
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
| `zs` | A random calm scene |
| `zs <scene>` | One scene by name, such as `zs koi-pond` |
| `zs list` | Every scene marked pass, fail or general, plus the sound sets |
| `zs sounds [set] [event]` | Plays one sound set. With no set it plays every set's pass tone in turn |
| `zs config` | Opens `scenes.toml` in the editor |
| `zs new <name>` | Writes a starter Lua scene into `~/.config/zacess/scenes` |
| `zs snap <scene>` | Writes an SVG still of a scene |
| `zs themes` | The themes and which one is active |
| `zw` | Watches the build in the current Rust project (`cargo check`) |
| `zwc` | The same with Clippy |
| `zwt` | The same with the tests |
| `zwa` | The same with check-all |

While a scene runs, `n` and `b` switch scenes. In watch mode `m` changes the sound set. The volume goes up with `+` and down with `-`. `q` quits.

## Verify

1. `zacess-scenes --version` shows the newest release.
2. `zacess-scenes config path` points at the linked `scenes.toml`.
3. `zs` shows a scene in the current Zacess theme. After `zt deep-light` the next `zs` shows Deep Contrast Light.
4. `zw` in a Rust project shows ALL GOOD and a breaking change turns it to BUILD FAILED.
