# Accessibility

These dotfiles started from a practical need. With monocular vision, depth cues are weak and a monochrome terminal reads as one flat wall of text. Distinct colours take over the job of telling one kind of line from another. Short commands cut down how much exact typing a day needs. The [README](README.md#about) tells the full story. The same choices help anyone who scans a terminal quickly, works with a colour vision difference or finds long commands tiring to type.

> [!NOTE]
> Some of these settings are preferences rather than requirements. Change them freely in your own copy. If a change would help other people too, open an issue or a pull request so I can consider it for everyone.

## Vision

| Need | What the profile does |
| --- | --- |
| Monocular vision or weak depth perception | Every kind of output has its own colour, so a line is recognised before it is read: red for errors, green for success, cyan for progress and information, yellow for warnings and dates, magenta for section headers in `cmds`, white for descriptions |
| Scanning long output | Section headers are bold as well as coloured, so the structure still shows when colours are weak or reduced |
| Low vision | Colours use the terminal's named ANSI slots, not fixed hex values, so a high-contrast terminal theme or a larger font applies to everything the profile prints |
| Colour vision differences | Status messages carry words as well as colour ("profile loaded", the error text itself). The colours were tested on dark and light terminal themes. Changing one colour in `02-colours` updates it across the whole profile |
| Icon fonts | The Starship prompt's own symbols are plain ASCII (the `>` prompt character, `+` for jobs and `!`, `^` or `v` in git status), so it reads cleanly without a Nerd Font. The Node.js module shows the plain text `node` rather than Starship's default Nerd Font glyph. The terminals on my Mac use Monaco 12 in iTerm2 and Warp's default font at size 13, neither of them a Nerd Font |

The terminal itself sets the final shades. A pure black background with light grey text, as used in [terminal-config](https://github.com/zaccesss/terminal-config), gives a contrast ratio of about 11:1. The starter configs there set `SF Mono`, which only macOS ships, so on Linux and Windows those apps fall back to their own default monospace font until it is swapped for one that is installed.

> [!WARNING]
> The Starship prompt shows the same `>` symbol after every command, green after success and bright red after a failure, so that one signal relies on colour alone. With red and green hard to tell apart, change `error_symbol` in `starship.toml` to a different character, for example `[x](bold bright-red)`.

## Typing and memory

- Short aliases replace the commands used most: `gs` for `git status`, `dcu` for `docker-compose up -d`. Fewer keystrokes means fewer chances for a typo to break a long command.
- The same alias works on macOS, Linux and Windows, so one set of muscle memory covers every machine.
- Helpers remove flags that are hard to remember: `extract` unpacks any archive, `please` reruns the last command with `sudo` (elevated on Windows).
- `cmds` prints every alias and function with a one-line description, grouped by topic and paged so it can be scrolled at any pace. Press `q` to leave. `listcmds` lists everything actually loaded.

## Colour in other tools

- `ls` shows directories in bold cyan, symlinks in magenta and executables in bold green.
- `grep` and `diff` highlight matches inline.
- Man pages show headers in bold cyan, emphasis underlined in green and search hits in yellow.

## Known gaps

- The profile does not yet honour the `NO_COLOR` convention. Setting the colour variables in `02-colours` to empty strings removes colour from the profile's own messages, while the prompt and `ls` keep theirs.

## Feedback wanted

If something here gets in the way, open an [issue](https://github.com/zaccesss/dotfiles/issues/new/choose) describing what happened and what would work better.

## The shared statement

> [!NOTE]
> I keep one shared accessibility statement for all my projects: [zaccesss/accessibility](https://github.com/zaccesss/accessibility) or on [my site](https://isaacadjei.me/accessibility). This file takes precedence where the two differ.
