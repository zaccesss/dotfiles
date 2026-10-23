# How this repository is maintained

Everything under `.github/` serves the whole repository. Each folder keeps its own README, guides
and screenshots, but there is one workflow, one set of issue forms and one pull request template.

## Workflow

There is one workflow, [`workflows/ci.yml`](workflows/ci.yml). It runs on every push to `main`, on
every pull request and on demand from the Actions tab. Its first job works out which folders
changed, then each folder's own checks run only when that folder changed. A change to `ci.yml`
itself runs every check. A skipped job reports as passing, so a pull request never waits on a
folder it did not touch.

| Job | Runs | What it checks |
| --- | --- | --- |
| Changes | Always | Which folders the push or pull request touched, using `dorny/paths-filter` |
| Lint markdown files | Always | Every Markdown file against [`.markdownlint.json`](../.markdownlint.json) |
| Lint shell scripts | Always | ShellCheck on the shell profiles (bash compatibility mode for zsh), the Git hooks (POSIX sh), the preference scripts and the Linux bootstrap, plus a syntax check of the preference scripts |
| root: Repository files | Root or `.github/` changed | Every YAML file under `.github/` parses |
| shell: Syntax | `shell/`, the root `mac/`, `linux/` or `windows/`, `editors/` or `apps/` changed (`zt` calls their apply scripts) | zsh and bash syntax of every profile and topic file, a parse of every PowerShell file, a compile of the Python scripts and ruff on them |
| mac-bootstrap: Tests (macOS) | `setup/mac-bootstrap/` changed | Syntax with the stock bash 3.2, ShellCheck and the offline test suite on a real macOS runner |
| linux-bootstrap: Tests | `setup/linux-bootstrap/` changed | Syntax, ShellCheck and the offline test suite on Ubuntu 24.04 for amd64 and arm64 |
| linux-bootstrap: Packages | `setup/linux-bootstrap/` changed, pull requests only | Every package and optional extra resolves in clean Ubuntu 24.04 and 26.04 containers on amd64 and arm64 |
| windows-bootstrap: Tests (Windows) | `setup/windows-bootstrap/` changed | PSScriptAnalyzer, the Pester tests and a full plan-mode run on a Windows runner |
| windows-bootstrap: Package list (winget) | `setup/windows-bootstrap/` changed | Every winget identifier in the package list still exists |
| defaults: Tests (macOS) | `setup/defaults/` changed | The macOS defaults tests on the stock bash 3.2 |
| defaults: Tests (Windows) | `setup/defaults/` changed | PSScriptAnalyzer and the Pester tests, including a registry round trip on a throwaway key |
| terminal: Validate config files | `terminal/terminal/` changed | Every generated theme matches the palette and meets its contrast floor, the macOS installer passes ShellCheck and every TOML and Hyper config parses |
| tmux: Start a session with the config | `terminal/tmux/` changed | A real tmux session starts with the config |
| cli-tools: Smoke test ripgrep, fzf and lazygit | `terminal/cli-tools/` changed | Each tool runs with its config |
| gitconfig: Validate platform config files | `git/gitconfig/` changed | All three files parse and differ only where they should |
| git-hooks: Syntax | `git/git-hooks/` changed | Every hook parses as POSIX sh |
| ssh: Parse | `git/ssh/` changed | Each platform config parses on its own real OS (macOS, Ubuntu and Windows) |
| ssh: Confirm the only difference and scan for private keys | `git/ssh/` changed | Only `UseKeychain` differs between platforms and nothing shaped like a private key is present |
| vscode: Validate JSON config | `editors/vscode/` changed | Every settings, keybindings, snippet and template file parses and the extension list is well formed |
| zed: Validate settings and extensions | `editors/zed/` changed | `settings.json` parses, the extension list is well formed, the theme file matches its package, the shell apply scripts match and pass ShellCheck and the PowerShell script parses |
| jetbrains: Validate config and plugin lists | `editors/jetbrains/` changed | Keymaps and Toolbox settings parse, the Toolbox files differ only where they should, the plugin lists are well formed, the theme plugin is pinned with a full digest, the shell apply scripts match and pass ShellCheck and the PowerShell script parses |
| eclipse: Validate preferences and merge scripts | `editors/eclipse/` changed | Every preference fragment is well formed, the merge script runs twice on a throwaway workspace with no change the second time and the PowerShell script parses |
| stm32cubeide: Validate preferences and merge scripts | `editors/stm32cubeide/` changed | The same as Eclipse, plus the C colours in every theme and the default workspace search |
| xcode: Validate preferences, themes and the install script | `editors/xcode/` changed | `prefs.txt`, the themes and the key bindings file parse and the install script passes ShellCheck |
| neovim: Load config headlessly | `editors/neovim/` changed | Neovim starts with the config |
| arduino: Validate settings and apply scripts | `editors/arduino/` changed | The settings name a packaged theme and Geist Mono, the theme package pins a release with a full digest, the shell scripts match and pass ShellCheck and the PowerShell script parses |
| microchip-studio: Validate themes and apply script | `editors/microchip-studio/` changed | Every theme holds only the Fonts and Colors category with Geist Mono and the editor items and the PowerShell script parses |
| kicad: Validate themes and apply scripts | `editors/kicad/` changed | Every theme holds every colour key and meets its contrast floors, the shell scripts match and pass ShellCheck and the PowerShell script parses |
| processing: Validate themes and apply scripts | `editors/processing/` changed | Every theme carries its marker line and meets its contrast floor, the font key is set, the shell scripts match and pass ShellCheck and the PowerShell script parses |
| nextpad-plus-plus: Validate themes and apply script | `editors/nextpad-plus-plus/` changed | Every theme parses and meets its contrast floor with Geist Mono and the apply script passes ShellCheck |
| vivado: Validate themes and apply scripts | `editors/vivado/` changed | Every theme holds the editor colours and the 21 syntax styles in Vivado's formats and meets its contrast floor, the Linux script passes ShellCheck and the PowerShell script parses |
| notepad-plus-plus: Validate themes and apply script | `editors/notepad-plus-plus/` changed | Every theme is well formed with Geist Mono and valid colours and the PowerShell script parses |
| thonny: Validate themes and apply scripts | `editors/thonny/` changed | The plugin defines all eight themes, every platform's settings name a theme and Geist Mono, the shell scripts pass ShellCheck and the PowerShell script parses |
| matlab: Validate themes and apply scripts | `editors/matlab/` changed | Every theme names a desktop theme and RGB colours, every platform names Geist Mono, the shell scripts pass ShellCheck and the PowerShell script parses |
| ltspice: Validate themes and apply scripts | `editors/ltspice/` changed | Every theme sets the same colour entries with 24-bit values, the shell scripts pass ShellCheck and the PowerShell script parses |
| proteus: Validate themes and apply scripts | `editors/proteus/` changed | Every theme has a short unique set name, valid PCB values and the default template's schematic slots and the PowerShell scripts parse |
| raycast: Check extension list format | `apps/raycast/` changed | The extension list is well formed |
| rectangle: Validate Rectangle config | `apps/rectangle/` changed | `RectangleConfig.json` has the shape Rectangle expects |
| zotero: Validate settings and apply scripts | `apps/zotero/` changed | Every theme maps to a mode and a built-in reader theme, the shell scripts pass ShellCheck and the PowerShell script parses |
| obsidian: Validate settings and apply scripts | `apps/obsidian/` changed | Every theme maps to a base and a variant, the theme package pins a release with a full digest, the shell scripts pass ShellCheck and the PowerShell script parses |

## Issue forms and templates

| File | What it is for |
| --- | --- |
| [`ISSUE_TEMPLATE/bug_report.yml`](ISSUE_TEMPLATE/bug_report.yml) | Bug report form with a "Which tool?" dropdown listing every folder |
| [`ISSUE_TEMPLATE/feature_request.yml`](ISSUE_TEMPLATE/feature_request.yml) | Feature request form with the same dropdown |
| [`ISSUE_TEMPLATE/config.yml`](ISSUE_TEMPLATE/config.yml) | Turns off blank issues and links the security policy and contact routes |
| [`pull_request_template.md`](pull_request_template.md) | The pull request template, with a checklist of every folder |
| [`dependabot.yml`](dependabot.yml) | Weekly updates for the GitHub Actions the workflow uses |
| [`FUNDING.yml`](FUNDING.yml) | The sponsor links shown on the repository page |

The root [CODEOWNERS](../CODEOWNERS) file asks for a review on every pull request.
