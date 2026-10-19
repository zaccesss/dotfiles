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

The terminal itself sets the final shades. The High Contrast palette in [terminal-config](https://github.com/zaccesss/terminal-config) gives near-white text on black at 15.9:1 in dark mode and near-black text on white at 16.5:1 in light mode, with all 16 colours set and every light-mode colour at 7:1 or more. Terminals that support it switch between the two with the system appearance. Everything this profile prints follows, since it only uses the named colours.

> [!TIP]
> `termtheme` sets the terminal's light and dark behaviour in one command on every platform.
> `termtheme dark` or `termtheme light` keeps the High Contrast palette on one mode whatever the
> system does, `termtheme auto` follows the system's light and dark setting and `termtheme` on its
> own shows which mode is on. It drives Terminal.app on macOS, Ptyxis on Linux and Windows Terminal.

> [!WARNING]
> The Starship prompt shows the same `>` symbol after every command, green after success and bright red after a failure, so that one signal relies on colour alone. With red and green hard to tell apart, change `error_symbol` in `starship.toml` to a different character, for example `[x](bold bright-red)`.

## Typing and memory

- Short aliases replace the commands used most: `gs` for `git status`, `dcu` for `docker-compose up -d`. Fewer keystrokes means fewer chances for a typo to break a long command.
- The same alias works on macOS, Linux and Windows, so one set of muscle memory covers every machine.
- Helpers remove flags that are hard to remember: `extract` unpacks any archive, `please` reruns the last command with `sudo` (elevated on Windows).
- `cmds` prints every alias and function with a one-line description, grouped by topic and paged so it can be scrolled at any pace. Press `q` to leave. `listcmds` lists everything actually loaded.

## Typed-command colours

Commands are coloured as they are typed, the same meanings on every platform: a known command, alias, function or builtin in green, an unknown command in red, a quoted string in yellow and an option (`-x` or `--long`) in cyan, with everything else in the terminal's default colour. macOS and Linux use zsh-syntax-highlighting (installed with the profile, silently skipped when absent); Windows uses PowerShell's built-in PSReadLine with the same colours.

- The colours are the normal (not bright) ANSI ones, since the High Contrast palette makes the bright variants paler.
- Colour here is always a second signal, never the only one: a bad command still fails to run with its own error, so nothing depends on noticing the red. PSReadLine cannot tell a known command from an unknown one, so Windows does not colour unknown commands at all; the failure on running them is the signal there.

## Finding a command's output

Long output makes it hard to see where one command ended and the next began. The profile marks where each prompt, command and output starts and ends (OSC 133 shell integration), so the terminal can jump straight from one command to the next and select a single command's output without dragging across the screen.

| Terminal | Keys |
| --- | --- |
| Terminal.app on macOS | `Cmd+Up` and `Cmd+Down` jump to the previous or next prompt. Terminal.app marks prompts by itself |
| VS Code's terminal | VS Code's own shell integration: `Ctrl+Up` and `Ctrl+Down` (`Cmd+Up` and `Cmd+Down` on macOS) |
| Windows Terminal | Jump and select actions bound in its own settings, which are not part of these dotfiles. The [Windows guide](guides/windows.md#command-marks) has the setup |

- `copyout` runs a command and copies all of its output to the clipboard, so a long result can be pasted somewhere easier to read without selecting it by hand.
- `logrun` saves a command's output to a dated file in `~/logs`, so it can be read later in an editor at any size and pace.

## Colour in other tools

- The welcome banner labels each line (Machine, Shell and Session) and gives each value its own colour (green, magenta and yellow) under a bold cyan heading, so colour is never the only signal. Its line-drawing borders use the terminal's own text colour.
- The banner is plain text with no emoji, so it looks the same in every terminal and a screen reader does not announce pictures. It uses the normal ANSI colours rather than the bright ones, which the High Contrast palette makes paler.
- `games` can be played without colour: 2048 tiles show their numbers, Word marks every letter with a symbol (`^` right place, `~` wrong place and `.` not in the word). Blocks pieces differ by shape. Only Snake, Blocks and Meteors are timed. Each of them has a pause key. A new best score says "New best" in words as well as turning yellow. Q or Esc leaves any game and a key hint is always on screen.
- fzf uses the terminal's own colours with yellow matches. The current line is bold and reversed rather than shaded, so it reads in light and dark mode alike.
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
