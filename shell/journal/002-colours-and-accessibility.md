# 008 - Colour choices and why they matter

**Date:** June 2026
**Status:** Complete

---

## The personal context

I lost sight in my right eye at age two due to retinoblastoma. I have worked with monocular vision my entire life. Most of the time it is not a significant factor in day-to-day computing, but there are places where it shows up - depth perception on 3D UIs, parallax-heavy interfaces and long terminal sessions where visual scanning matters.

The terminal is one of those places. A terminal with no colour is a wall of text. With monocular vision you cannot rely as much on the spatial layout clues that binocular vision provides - the slight sense of layers and depth that helps the brain pre-parse where sections begin and end. Colour takes over that job. A clearly colour-coded terminal means I can scan `cmds` output in seconds rather than reading each line.

This is partly why the colour scheme in these dotfiles is deliberate and not just aesthetic. The choices were also made to hopefully be useful to others who navigate the same thing.

---

## The colour variables

`02-colours.zsh` (and its Linux and Windows equivalents) defines a set of ANSI escape variables used across the profile:

```zsh
BOLD='\033[1m'
DIM='\033[2m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
RESET='\033[0m'
```

These are used consistently:

| Colour | Where it is used | Why that colour |
| --- | --- | --- |
| Cyan (bold) | Welcome banner border, header line | Distinct from text, high contrast on both dark and light backgrounds |
| Magenta (bold) | Section headers in `cmds()` | Visually distinct from cyan - separates structure from commands at a glance |
| Cyan | Command names in `cmds()` | Commands stand out against descriptions |
| White | Descriptions in `cmds()`, parenthetical expansion lines | Plain text, readable, no distraction |
| Green | "profile loaded" line in welcome banner, success messages | Standard convention for OK/success |
| Yellow | Date and time line in welcome banner | Warm colour draws the eye, clearly separates the date from the status lines |
| Red | Error messages | Standard convention for errors |
| Bold | Section headers | Weight rather than colour for structure - works even if colours are reduced |

The welcome banner itself uses a specific layout:

```
---------------------------------------------
  Welcome back, Isaac!
  MacBook Air - zsh
  Thu 05 Jun 2026  09:42
  macOS profile loaded
---------------------------------------------
```

Every line is a different colour. The border is cyan and bold. The name line is cyan. The machine line is green. The date is yellow. The loaded confirmation is green. Even in a quick glance at a new terminal tab, each line reads immediately without having to parse the text.

---

## The `cmds()` function

`cmds()` prints a long structured output grouped by topic, piped through `less` (Windows: `Out-Host -Paging`). The output uses a 3-colour scheme: **MAGENTA (bold)** for section headers, **CYAN** for command names and **WHITE** for short descriptions. Parenthetical expansion lines (e.g. `(list / split / kill)`) are also WHITE. This separates structure, commands and explanatory text at a glance without reading every word. Pressing `q` exits back to the shell exactly as it was, the same interaction as `git diff` or `man`.

This went through two earlier designs before landing here: a cursor save/restore pattern first, then a plain alternate-screen-buffer switch. Both broke in different ways once the real content (over 250 lines) was longer than one screen. Piping through a real pager was the fix. A pager is built to manage exactly this: its own internal scroll position, real mouse-wheel and keyboard scrolling, a clean single-keypress exit, all without leaking any state onto the shell prompt underneath. `cmds` is long precisely because I scan it visually rather than reading top to bottom. With monocular vision, disorientation while hunting for a mid-scroll position is worse than it might be otherwise, so a pager that handles its own scrolling and exits cleanly matters more here than it would for a short command.

---

## Accessibility for others

The choices made here - high-contrast distinct colours per section, bold headers, cursor restore after long output - are not just for my specific situation. They help anyone who:

- Has any degree of colour vision deficiency (the cyan, green and yellow chosen are distinguishable under common deuteranopia and protanopia simulations)
- Uses a terminal with a white or light background (the colours were tested on both dark and light themes)
- Runs `cmds` frequently and wants a quick scan, not a full read
- Finds monochrome terminal output hard to navigate quickly

The `02-colours.zsh` variables are easy to change. If a particular terminal theme makes cyan hard to see, changing the `CYAN` variable in one place updates the entire profile.
