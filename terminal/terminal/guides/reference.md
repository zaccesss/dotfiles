# Reference

## Palette

| Setting | Value | Why |
| --- | --- | --- |
| Dark background | `#000000` | Pure black gives the strongest contrast against light text and is easy on the eyes in a dark room. |
| Dark text | `#e0e0e0` | Near-white rather than pure white, which glares against pure black over a long session. |
| Light background and text | `#ffffff` and `#1f1f1f` | The same contrast, the other way round. |
| ANSI colours | all 16 set, per theme | So every terminal draws the same command in the same colours. Every value is in [themes.md](themes.md). |

## Why one palette for every terminal

A published theme looks coordinated but is chosen for looks. This palette is chosen for contrast and
readability: saturated colours that are easy to tell apart, with every light-mode colour at 7:1 or
more. Using it in every terminal means switching between them changes nothing about how text reads.
Leaving the 16 colours at each terminal's defaults would make the same output look different in
each app.

## Other settings

| Setting | Value | Why |
| --- | --- | --- |
| Font size | `13` | A comfortable default that fits a wide terminal window on a laptop screen. |
| Scrollback | `10000` lines | Enough history to scroll back through a long build log. |
| Opacity | `1.0` | Fully opaque, since transparency reduces contrast. |
| Padding (Alacritty) | `10` px | Keeps text off the window edge. |

## Fonts per platform

| Platform | Font | Why |
| --- | --- | --- |
| macOS | `SF Mono` | Ships with macOS. |
| Linux | `GeistMono Nerd Font` | Free, close to SF Mono's look and carries the Nerd Font symbols a prompt uses. |
| Windows | `GeistMono Nerd Font` | Same font as Linux. |

SF Mono's licence limits it to Apple's own apps, so it is not offered on Linux or Windows. Install
`GeistMono Nerd Font` (released under the SIL Open Font License) from the
[Nerd Fonts releases](https://github.com/ryanoasis/nerd-fonts/releases) before using the Linux or
Windows configs. A terminal whose font is missing falls back to its own default monospaced font
rather than failing, but prompt icons will not render. Swap in any monospaced font you have
installed; a patched Nerd Font is needed if you use icons in your prompt.

## Why no Kitty on Windows

Kitty has no native Windows build, so there is no `windows/kitty/` folder.
