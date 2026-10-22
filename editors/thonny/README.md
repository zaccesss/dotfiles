# thonny

Thonny settings: all eight Zacess themes as a Thonny plugin, Geist Mono and larger editor text.

## What it sets

| Setting | Value | Why |
| --- | --- | --- |
| `[view] ui_theme` and `syntax_theme` | `Zacess Deep Contrast Dark` | The default theme. `-Theme` (`--theme` on Linux) picks any of the eight |
| `[view] editor_font_family` and `io_font_family` | `GeistMono NF` on Windows, `GeistMono Nerd Font` elsewhere | Geist Mono's Nerd Font build. Tk on Windows looks fonts up by their short GDI name |
| `[view] editor_font_size` and `io_font_size` | `16` | Larger than the default |
| `[view] highlight_current_line` and `show_line_numbers` | `True` | Easier to keep your place |

The themes are a Thonny plugin, [`shared/thonnycontrib/zacess_themes`](shared/thonnycontrib/zacess_themes), built by [`scripts/build-themes.py`](scripts/build-themes.py) from the Zacess Themes `.vsix`. Each theme has a syntax half and an interface half built on Thonny's own Clean themes, so menus, the shell and the editor all match.

## Apply

Quit Thonny first: it writes `configuration.ini` back when it exits, so the scripts refuse to run while it is open. It also has to have been started once.

```powershell
pwsh -File windows\apply.ps1
pwsh -File windows\apply.ps1 -Theme cream
```

```bash
mac/apply.sh
mac/apply.sh --theme cream
linux/apply.sh
linux/apply.sh --theme cream
```

The work is done by [`shared/apply.py`](shared/apply.py), run with the Python that has Thonny in it: Thonny's own `python.exe` on Windows, the Python bundled inside `Thonny.app` on macOS (settings in `~/Library/Thonny`), the system Python for a `dnf` or `apt` install on Linux or the `org.thonny.Thonny` Flatpak's. The macOS script looks in `/Applications`, then `~/Applications`; another `Thonny.app` can be passed as an argument. That Python knows where its Thonny keeps plugins and settings. Only the tracked `[view]` keys and the interpreter change. The script prints each as `added`, `changed` or `unchanged`. Running it again changes nothing. Nothing is backed up.

## Its own virtual environment

Thonny runs code in a virtual environment kept for it at `~/.venvs/thonny` (`%USERPROFILE%\.venvs\thonny` on Windows), so packages from **Tools > Manage packages** stay out of the system Python. The apply script makes it only when it is missing and never rebuilds it:

| Platform | Made from |
| --- | --- |
| Windows | Python 3.15 from the Python install manager (`py install 3.15`) |
| macOS | Homebrew's `python@3.15` |
| Linux | `uv` with Python 3.15 when uv is installed, otherwise `python3.15` or `python3` |

The script then makes it Thonny's interpreter and puts it first in Thonny's list of recent interpreters, so any earlier choice is still a click away in **Tools > Options > Interpreter**. A Flatpak Thonny cannot run a Python from outside its sandbox, so it keeps its own interpreter.

## Its projects folder

Thonny starts in `~/dev/projects/python` (`[run] working_directory`), the projects folder every editor shares on every machine. The script makes the folder when it is missing.

## Check it worked

1. Start Thonny. **Tools > Options > Theme & Font** shows the Zacess theme for both the interface and the syntax, with Geist Mono at 16 (GeistMono Nerd Font Mono on macOS).
2. A Python file shows keywords, strings and comments in the theme's colours.

## Validation

[`scripts/validate.py`](scripts/validate.py) runs in CI on Linux. It checks the plugin and apply script parse, the plugin defines all eight themes and every platform's settings name a Zacess theme and Geist Mono.
