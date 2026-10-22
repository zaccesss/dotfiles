# Accessibility

This repository started from a practical need. I have monocular vision, so depth cues are weak and
a monochrome screen reads as one flat wall of text. Distinct, high-contrast colours take over the
job of telling one kind of line from another, short commands cut down how much exact typing a day
needs and the same layout on every machine means nothing has to be relearnt. The same choices help
anyone who scans a screen quickly, works with a colour vision difference or finds long commands
tiring to type.

## The shared promise

Every folder in this repository follows the same rules:

- **One set of themes everywhere.** Terminals, editors and IDEs all use the eight Zacess themes,
  with Zacess Deep Contrast Dark as the default, so switching tools never changes how the screen
  reads. `zt` in the [shell](shell/README.md) switches every installed tool at once.
- **Colour is never the only signal.** Status, errors and warnings carry words as well as colour.
  Bold or underline marks structure where colour might be weak.
- **Named colours, not fixed values.** Wherever a tool allows it, output uses the terminal's named
  colour slots, so a higher-contrast theme or a larger font applies everywhere.
- **The same keys on every platform.** Custom bindings use one `Cmd+Alt` (macOS) or `Ctrl+Alt`
  (Windows and Linux) pair. Vi-style `h`, `j`, `k` and `l` movement works the same way in Neovim,
  tmux and lazygit.
- **Readable runs.** The bootstraps start every message with a word label (`[INFO]`, `[ OK ]`,
  `[WARN]` or `[ERROR]`), so a run reads correctly without colour.

## Each folder's own statement

Each folder says exactly what it changes and what it cannot change yet.

| Folder | Statement |
| --- | --- |
| shell | [shell/ACCESSIBILITY.md](shell/ACCESSIBILITY.md) |
| mac-bootstrap | [setup/mac-bootstrap/ACCESSIBILITY.md](setup/mac-bootstrap/ACCESSIBILITY.md) |
| linux-bootstrap | [setup/linux-bootstrap/ACCESSIBILITY.md](setup/linux-bootstrap/ACCESSIBILITY.md) |
| windows-bootstrap | [setup/windows-bootstrap/ACCESSIBILITY.md](setup/windows-bootstrap/ACCESSIBILITY.md) |
| defaults | [setup/defaults/ACCESSIBILITY.md](setup/defaults/ACCESSIBILITY.md) |
| terminal | [terminal/terminal/ACCESSIBILITY.md](terminal/terminal/ACCESSIBILITY.md) |
| tmux | [terminal/tmux/ACCESSIBILITY.md](terminal/tmux/ACCESSIBILITY.md) |
| cli-tools | [terminal/cli-tools/ACCESSIBILITY.md](terminal/cli-tools/ACCESSIBILITY.md) |
| vscode | [editors/vscode/ACCESSIBILITY.md](editors/vscode/ACCESSIBILITY.md) |
| zed | [editors/zed/ACCESSIBILITY.md](editors/zed/ACCESSIBILITY.md) |
| jetbrains | [editors/jetbrains/ACCESSIBILITY.md](editors/jetbrains/ACCESSIBILITY.md) |
| eclipse | [editors/eclipse/ACCESSIBILITY.md](editors/eclipse/ACCESSIBILITY.md) |
| stm32cubeide | [editors/stm32cubeide/ACCESSIBILITY.md](editors/stm32cubeide/ACCESSIBILITY.md) |
| xcode | [editors/xcode/ACCESSIBILITY.md](editors/xcode/ACCESSIBILITY.md) |
| neovim | [editors/neovim/ACCESSIBILITY.md](editors/neovim/ACCESSIBILITY.md) |
| arduino | [editors/arduino/ACCESSIBILITY.md](editors/arduino/ACCESSIBILITY.md) |
| microchip-studio | [editors/microchip-studio/ACCESSIBILITY.md](editors/microchip-studio/ACCESSIBILITY.md) |
| kicad | [editors/kicad/ACCESSIBILITY.md](editors/kicad/ACCESSIBILITY.md) |
| vivado | [editors/vivado/ACCESSIBILITY.md](editors/vivado/ACCESSIBILITY.md) |
| processing | [editors/processing/ACCESSIBILITY.md](editors/processing/ACCESSIBILITY.md) |
| notepad-plus-plus | [editors/notepad-plus-plus/ACCESSIBILITY.md](editors/notepad-plus-plus/ACCESSIBILITY.md) |
| nextpad-plus-plus | [editors/nextpad-plus-plus/ACCESSIBILITY.md](editors/nextpad-plus-plus/ACCESSIBILITY.md) |
| thonny | [editors/thonny/ACCESSIBILITY.md](editors/thonny/ACCESSIBILITY.md) |
| matlab | [editors/matlab/ACCESSIBILITY.md](editors/matlab/ACCESSIBILITY.md) |
| ltspice | [editors/ltspice/ACCESSIBILITY.md](editors/ltspice/ACCESSIBILITY.md) |
| proteus | [editors/proteus/ACCESSIBILITY.md](editors/proteus/ACCESSIBILITY.md) |
| raycast | [apps/raycast/ACCESSIBILITY.md](apps/raycast/ACCESSIBILITY.md) |
| rectangle | [apps/rectangle/ACCESSIBILITY.md](apps/rectangle/ACCESSIBILITY.md) |
| obsidian | [apps/obsidian/ACCESSIBILITY.md](apps/obsidian/ACCESSIBILITY.md) |
| zotero | [apps/zotero/ACCESSIBILITY.md](apps/zotero/ACCESSIBILITY.md) |

The gitconfig, git-hooks and ssh folders change nothing about how anything looks or is operated, so
they carry no statement of their own.

## Feedback wanted

If something here gets in the way, open an
[issue](https://github.com/zaccesss/dotfiles/issues/new/choose) describing what happened and what
would work better. An accessibility problem is treated as a bug.

## The shared statement

> [!NOTE]
> I keep one shared accessibility statement for all my projects:
> [zaccesss/accessibility](https://github.com/zaccesss/accessibility) or on
> [my site](https://isaacadjei.me/accessibility). This file and the folder statements take
> precedence where they differ.
