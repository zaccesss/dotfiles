# stm32cubeide

> STM32CubeIDE preferences: the eight Zacess colour themes mapped to C, Geist Mono, 15 VS Code style key bindings and a merge script per platform that applies them to a workspace without touching anything else.

STM32CubeIDE is ST's Eclipse-based IDE for STM32 microcontrollers. It sits on Eclipse (4.38 in STM32CubeIDE 2.2) with CDT for C and C++, so like Eclipse it keeps preferences in `.prefs` files inside each workspace's `.metadata` folder, mixed in with values it writes for itself (window state, recent files, debug probes, toolchain paths). Copying those files over would wipe all of that, so this folder tracks only the keys that were deliberately changed and merges them in. The Eclipse IDE counterpart is [eclipse](../eclipse). STM32CubeIDE gets its own folder because it edits C through CDT and keeps its own workspace.

## What's here

- **`shared/prefs/`** - the tracked keys, one fragment per `.prefs` file: autosave every 20 seconds, line numbers, spaces for tabs at width 4, current line highlight, spell checking in British English (C files included) and the 15 key bindings. Every key explained in [guides/reference.md](guides/reference.md).
- **`<platform>/prefs/`** - the editor, C editor and Terminal font for each platform: GeistMono Nerd Font at 18 points on the Mac and 14 on Windows and Linux, which matches on screen. The Terminal uses its Nerd Font Mono variant, whose icons fit one cell.
- **`shared/theme/`** - the eight Zacess themes for STM32CubeIDE, built by [`scripts/build-themes.py`](scripts/build-themes.py) from the Zacess Eclipse themes: editor colours, C syntax and semantic colours, Doxygen comments and the Terminal palette, plus tab outlines for the two Deep Contrast themes. The apply scripts merge Zacess Deep Contrast Dark by default. `--theme` picks another.
- **`<platform>/apply.sh`** and **`windows/apply.ps1`** - find the workspace, merge the fragments and the chosen theme in key by key and print what changed. They refuse to run while STM32CubeIDE is open and make no backup: this folder holds every value they write and every other key is left as it was.
- **`<platform>/README.md`** - installing STM32CubeIDE on that platform.

## Per-platform differences

One, the font size. Every platform uses GeistMono Nerd Font through the short font string `1|GeistMono Nerd Font|<size>|0|`, which has no windowing system part, but points are larger on Windows and Linux, so their `prefs/` overlays use 14 where the Mac uses 18. The key bindings need no platform copy: they use Eclipse's `M1` to `M4` modifiers, so `M1+P` is `Cmd+P` on the Mac and `Ctrl+P` everywhere else. CI keeps `mac/apply.sh` and `linux/apply.sh` identical.

## Setup

```bash
git clone https://github.com/zaccesss/dotfiles.git ~/dev/github/repos/dotfiles
~/dev/github/repos/dotfiles/editors/stm32cubeide/<platform>/apply.sh
```

Replace `<platform>` with `mac` or `linux`. On Windows run `pwsh -File "$HOME\dev\github\repos\dotfiles\editors\stm32cubeide\windows\apply.ps1"`. With no workspace given, the scripts use the newest `~/STM32CubeIDE/workspace_<version>` that STM32CubeIDE has opened. Full walkthrough in [guides/setup.md](guides/setup.md).

> [!IMPORTANT]
> Quit STM32CubeIDE before running the script. It keeps preferences in memory and writes them back when it exits, so a merge made while it runs would be lost. The script checks and refuses.

## Structure

| Path | Contents |
| --- | --- |
| [`ACCESSIBILITY.md`](ACCESSIBILITY.md) | The Zacess theme, font size, autosave, spell checking and the key bindings |
| [`shared/prefs/`](shared/prefs/) | The tracked keys, merged on every platform |
| [`shared/theme/`](shared/theme/) | The eight Zacess themes for STM32CubeIDE and the Deep Contrast tab outlines |
| [`scripts/`](scripts/) | `build-themes.py`, which builds `shared/theme/` from the Zacess Eclipse themes |
| [`mac/`](mac/) | Merge script, the Mac font and the install steps |
| [`linux/`](linux/) | Merge script, font and the install steps for Fedora, Ubuntu and Debian |
| [`windows/`](windows/) | PowerShell merge script, font and the install steps |
| [`guides/`](guides/) | Install walkthrough and the full preferences and key binding reference |
