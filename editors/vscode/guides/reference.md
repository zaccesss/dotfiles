# Reference

Every `settings.json` key explained, the keybindings, the extension categories and what is
deliberately not tracked here.

## `settings.json`

| Key | Value | Why |
| --- | --- | --- |
| `workbench.colorTheme` | `Zacess Deep Contrast Dark` | Deep saturated colours at about 9:1 on black from the `zacess.zacess-themes` extension, for readability over a standard dark or light theme. |
| `window.autoDetectColorScheme` | `false` | The theme stays fixed whatever the system appearance. `true` switches between the two preferred themes with the system. |
| `workbench.preferredDarkColorTheme`, `workbench.preferredLightColorTheme` | `Zacess Deep Contrast Dark`, `Zacess Deep Contrast Light` | The pair used when `window.autoDetectColorScheme` is turned on. |
| `workbench.colorCustomizations` | the earlier High Contrast terminal palette, scoped to `Default High Contrast` and `Default High Contrast Light` | Only applies if one of the built-in high contrast themes is picked again. The Zacess themes carry their own 16 terminal colours. |
| `terminal.integrated.drawBoldTextInBrightColors` | `false` | Bold text keeps its colour rather than switching to the softer bright row. |
| `files.autoSave` | `onWindowChange` | Saves the moment focus leaves VS Code, without the noisy diffs `afterDelay` produces mid-edit. |
| `editor.wordWrap` | `on` | Long lines wrap instead of requiring horizontal scroll. |
| `editor.fontSize` | `14` | A readability preference. |
| `terminal.integrated.fontFamily` | `"GeistMono Nerd Font"` | The integrated terminal draws the Nerd Font symbols a themed prompt uses (branch, status and battery icons). The font is free under the SIL Open Font License and must be installed first, from the [Nerd Fonts releases](https://github.com/ryanoasis/nerd-fonts/releases). Without it the terminal falls back to a default monospaced font. The editor font itself is unchanged. |
| `git.autofetch` | `true` | Keeps remote tracking branches current without a manual `git fetch`. |
| `mssql.connectionGroups` | one empty `ROOT` group | The MSSQL extension's own default, kept explicit so a fresh install starts from a known empty state. |
| `mssql.autoDisableNonTSqlLanguageService` | `true` | Stops the MSSQL language service activating in files that are not T-SQL, avoiding false squiggles in other SQL dialects. |
| `diffEditor.maxComputationTime` | `0` | Removes the diff algorithm's time budget, so a very large diff still renders fully. |
| `debug.allowBreakpointsEverywhere` | `true` | Lets a breakpoint be set in a file VS Code would not otherwise recognise as debuggable, such as a generated file. |
| `C_Cpp.intelliSenseEngine` | `disabled` | Turns off the C/C++ extension's own IntelliSense engine, since `clangd` provides it through the STM32Cube extensions. Running both produces duplicate, conflicting diagnostics. |
| `stm32cube-ide-core.enableOfflineMode` | `false` | Lets the STM32Cube extension check for board and package updates online. |
| `terminal.integrated.persistentSessionReviveProcess` | `never` | A revived terminal session after a restart can reattach to a stale shell state. |
| `terminal.integrated.enablePersistentSessions` | `false` | A clean shell every time VS Code reopens, for the same reason. |
| `terminal.integrated.defaultProfile.windows` | `"PowerShell 7"` | On Windows, new terminals open PowerShell 7 through its launcher in `WindowsApps`, a path that stays the same when PowerShell updates. It starts with `-NoLogo`, so the version header and the profile load time message stay hidden. |
| `yaml.disableSchemaDetection` | workflow globs | Stops the YAML extension guessing a schema for CI workflow files, where the platform's own schema applies. |
| `discord.*`, `vscord.*` | file type only, no buttons | Both Discord presence extensions show only the file type (for example "Editing a TypeScript file") and never a file, workspace or repository name, so presence does not leak private project details. |

## `argv.json`

Launch-time flags. This is a different file from `settings.json` and lives at
`~/.vscode/argv.json` rather than in the user settings folder. Only `enable-crash-reporter` is set,
to VS Code's own default. VS Code generates a unique `crash-reporter-id` per install, so it is not
tracked: copying one machine's id onto another would make crash reports from two machines look like
the same install.

## Keybindings

[`keybindings/`](../keybindings/) holds 11 bindings per platform family. Each `command` id was checked
against the extension's own `package.json` `contributes.commands` first, since a wrong id fails
silently instead of raising an error:

| Key (macOS / Windows and Linux) | Command | What it does |
| --- | --- | --- |
| `cmd+alt+t` / `ctrl+alt+t` | `workbench.action.terminal.focus` | Focus the integrated terminal |
| `cmd+alt+r` / `ctrl+alt+r` | `workbench.action.tasks.test` | Run the default test task |
| `cmd+alt+w` / `ctrl+alt+w` | `editor.action.toggleWordWrap` | Per-file word wrap override, since `editor.wordWrap` is `on` globally |
| `cmd+alt+e` / `ctrl+alt+e` | `revealFileInOS` | Reveal the active file in the platform's file manager |
| `cmd+alt+b` / `ctrl+alt+b` | `gitlens.toggleFileBlame` | Toggle inline GitLens blame for the current file |
| `cmd+alt+d` / `ctrl+alt+d` | `errorLens.toggleError` | Toggle Error Lens inline diagnostics |
| `cmd+alt+q` / `ctrl+alt+q` | `sqltools.executeQuery` | Run the selected query in SQLTools |
| `cmd+alt+m` / `ctrl+alt+m` | `markdown.showPreviewToSide` | Open a live markdown preview beside the editor |
| `cmd+alt+shift+b` / `ctrl+alt+shift+b` | `platformio-ide.build` | Build the current PlatformIO project |
| `cmd+alt+shift+u` / `ctrl+alt+shift+u` | `platformio-ide.upload` | Upload firmware to the connected board |
| `cmd+alt+shift+m` / `ctrl+alt+shift+m` | `platformio-ide.serialMonitor` | Open the PlatformIO serial monitor |

Nothing VS Code already binds by default is rebound, only genuine gaps. The STM32 extensions
contribute no commands of their own, so there is no STM32 binding.

## Global snippets

`global.code-snippets` holds language-scoped snippets available in every project: a `todo`
comment for C-style, hash-style and SQL comment syntax. It also has a `dbg` print that labels a variable
with its own name for JavaScript, TypeScript, Python, C and C++, Java, Go and Swift. VS Code merges
them with any workspace-level snippets automatically.

## Extensions, by category

`extensions.txt` groups 95 extensions under `//` headers by rough purpose. The install command in
[setup.md](setup.md) filters the headers out. What each one does is in
[extensions.md](extensions.md).

| Category | Examples |
| --- | --- |
| C/C++ and embedded | `ms-vscode.cpptools*`, `llvm-vs-code-extensions.lldb-dap`, `platformio.platformio-ide`, `wokwi.wokwi-vscode`, the `stmicroelectronics.stm32cube-ide-*` set |
| Python and Jupyter | `ms-python.*`, `ms-toolsai.jupyter*` |
| Java and JVM | `redhat.java`, `vscjava.*`, `oracle.oracle-java` |
| .NET and C# | `ms-dotnettools.*` |
| Web and JavaScript | `bradlc.vscode-tailwindcss`, `dbaeumer.vscode-eslint`, `esbenp.prettier-vscode`, `ritwickdey.liveserver` |
| Go, PHP, Swift, PowerShell | `golang.go`, `bmewburn.vscode-intelephense-client`, `swiftlang.swift-vscode`, `ms-vscode.powershell` |
| Databases | `ms-mssql.*`, `cweijan.*`, `mtxr.sqltools`, `formulahendry.vscode-mysql` |
| Git and GitHub | `eamodio.gitlens`, `github.vscode-pull-request-github`, `github.vscode-github-actions` |
| Containers and cloud | `ms-azuretools.vscode-containers`, `ms-edgedevtools.vscode-edge-devtools` |
| Editor quality of life | `usernamehw.errorlens`, `streetsidesoftware.code-spell-checker`, `editorconfig.editorconfig`, `vscodevim.vim` |
| Formatting and viewing niceties | `davidanson.vscode-markdownlint`, `shd101wyy.markdown-preview-enhanced`, `tomoki1207.pdf`, `adpyke.codesnap` |
| Presence and time tracking | `icrawl.discord-vscode`, `leonardssh.vscord`, `wakatime.vscode-wakatime` |

## Templates

[`templates/`](../templates/) holds starting points for `launch.json` and `tasks.json`. VS Code
only reads those from a project's own `.vscode/` folder, so they are meant to be copied into a new
project and trimmed. See [templates/README.md](../templates/README.md).

## What is deliberately not tracked

- **`profiles/`, `workspaceStorage/`, `globalStorage/`, `History/` and `sync/`** - internal VS Code
  state and caches, generated by VS Code itself, with no good version to author.
- **Machine-specific paths** - for example a toolchain path baked into a `cmake.environment` entry,
  which breaks whenever the extension that owns that folder updates.
