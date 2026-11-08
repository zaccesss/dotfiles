# zacess-scenes

[Zacess Scenes](https://github.com/zacesshq/scenes) draws calm animated scenes in the terminal in the Zacess theme `zt` last set and watches a project in any language (a Rust build with [bacon](https://github.com/Canop/bacon)) or the commands typed in a shell: a calm scene while they pass and a storm while one fails, with short sounds. This folder holds my settings and the setup for macOS, Linux and Windows. The scenes and the program itself are described on [zacess.com/scenes](https://zacess.com/scenes/).

| File | Does |
| --- | --- |
| [`scenes.toml`](scenes.toml) | Example settings: a few pass and fail scenes on shuffle every 5 minutes (a scene run on its own too), calm motion, the bells sounds at volume 40 with the typo tone, quiet hours from 22:00 to 07:00 and the background sound off until `a` turns it on |
| [`setup.sh`](setup.sh) | macOS and Linux: the newest release binary into `~/.local/bin` checked against its checksum, bacon with cargo and `scenes.toml` linked to `~/.config/zacess/scenes.toml` |
| [`setup.ps1`](setup.ps1) | Windows: the same into `~\.local\bin` and `%APPDATA%\zacess\scenes.toml`, linked with Developer Mode on and copied otherwise |
| [`scenes/`](scenes/) | My own Lua scenes, linked one by one into the scenes folder beside `scenes.toml` by both setup scripts (see [My scenes](#my-scenes)) |

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

## My scenes

Eight scenes of my own, written in Lua against the [Lua scene API](https://github.com/zacesshq/scenes/blob/main/docs/lua.md). They load like the built-in ones, so `zs list` marks them as yours and `zs` can pick them at random.

| Scene | Kind | Shows |
| --- | --- | --- |
| [`hello-isaac`](scenes/hello-isaac.lua) | general | A big scrolling greeting for the time of day (good morning, good afternoon, good evening or late night) with the date. Behind it is a pixel sky tinted for the time with soft clouds, the sun crossing by the hour or a crescent moon at night. Rolling hills with trees run along the bottom. A line under it is typed over by a different project every nine seconds |
| [`now-building`](scenes/now-building.lua) | general | A departure board of my projects with a platform, tagline and status each that turn over like split flaps every ten seconds, plus a calling-at ticker of every tagline |
| [`lidarsat`](scenes/lidarsat.lua) | general | A pixel quadcopter over shaded hills and lit rooftops sweeping a fan of lidar rays at the ground. Every return stays on the land, so a point cloud grows behind it. A nav readout and a caption ticker sit on top |
| [`scope`](scenes/scope.lua) | general | A pixel oscilloscope in roll mode with a dotted graticule: a sine on channel 1 and a PWM square wave with a slowly drifting duty cycle on channel 2, each with a faint phosphor glow, plus readouts and a bench ticker |
| [`phaemos`](scenes/phaemos.lua) | general | A pixel motor and pump with four PHAEMOS nodes sending readings along a bus to the gateway, beside a scrolling vibration chart for each. The pump bearing wears to WATCH, gets a service estimate and is serviced again |
| [`build-passed`](scenes/build-passed.lua) | pass | BUILD PASSED AT 14:05 scrolling in the big font under pixel bunting with tumbling confetti. The ticker gives the time it passed, how long it has been green and the passing streak |
| [`build-failed`](scenes/build-failed.lua) | fail | BUILD FAILED AT 14:05 scrolling slowly over a pixel circuit board where one broken trace stops its signal at the gap. The ticker gives the time it failed, how long it has been failing and one small next step |
| [`football`](scenes/football.lua) | general | BUILD FC against BUGS on a striped pixel pitch with a goal and net, two kits (the away kit striped), a keeper and a crowd under the scoreboard. The teams pass the ball about calmly between results. A pass ends a short move in a goal: the net ripples, the scorer celebrates, the crowd does a slow wave and the scoreboard shows the score and GOAL AT 14:05. A fail ends it off the post or in the keeper's hands with the players holding their heads. Then the scoreboard gives one small next step. A ticker keeps the match report for the session: passes, fails, the streak and the time of the last result |

Run one with `zs <scene>`, such as `zs lidarsat`. For the build watcher, `zw --scene build-passed --fail-scene build-failed` uses the pair for one run. `football` handles both results itself, so `zw --scene football --fail-scene football` keeps the one match going and its score carries over from a pass to a fail. `build-passed`, `build-failed` and `football` are already in the `pass` and `fail` lists in `scenes.toml`, so the rotation picks them too.

Every scene draws with palette roles only, never a colour of its own, so it follows the theme `zt` set and keeps that theme's contrast in all ten Zacess themes, light ones included. Status is always a word as well as a colour (OK, WATCH, TESTING and the rest). Scrolling text moves in whole cells at a steady rate and loops without a seam; calm motion and reduced motion slow it further. Under reduced motion the rotors stop and the board's letters appear in place without flapping. Every scene passes the program's flash meter.

The scenes read the local time from `ctx.clock` and paint with the pixel canvas, both added to Zacess Scenes after 0.6.0. The pass and fail scenes and `football` take the time of a result from the moment the watch mode reports it, so a scene run on its own or just swapped in by the rotation leaves the time out rather than guess it. On an older release without the clock, `hello-isaac` says a plain hello and the times are left out. Without the canvas, every scene draws the same shapes in half-block characters instead.

To change one, edit it here: the link means the next start picks the change up. On Windows without Developer Mode the scenes are copied, so run the setup again with `-Link`. To check one, `zs snap <scene> --theme warm-light --out still.svg` draws a still and `zacess-scenes list` reports any scene that fails to load.

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
