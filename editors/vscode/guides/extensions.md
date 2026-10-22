# Extensions, in detail

What every installed extension does and when it actually gets used. Grouped the same way as the `//` headers in [`extensions.txt`](../extensions.txt).

## C/C++ and embedded

- **`ms-vscode.cpptools`** and **`ms-vscode.cpptools-extension-pack`** - Microsoft's C/C++ language support (IntelliSense, debugging, formatting). `C_Cpp.intelliSenseEngine` is set to `disabled` here specifically because `clangd` (below) replaces its IntelliSense. The pack's debugger and other tooling are still used.
- **`ms-vscode.cpptools-themes`** - Icon and colour theme bundled with the C/C++ extension pack.
- **`ms-vscode.cpp-devtools`** - Additional C/C++ developer tooling from Microsoft's own extension family.
- **`ms-vscode.cmake-tools`** - CMake project configuration, build and debug integration.
- **`stmicroelectronics.stm32cube-ide-*`** (11 extensions) - the full STM32Cube IDE toolchain ported to VS Code: core, build analyzer, bundled CMake, bundles manager, `clangd`-based IntelliSense, debug core plus 3 debugger backends (generic GDB server, J-Link, ST-Link), project manager, register viewer, RTOS awareness. Used together for STM32 microcontroller firmware development, this is why `stm32cube-ide-core.enableOfflineMode` is set in `settings.json`.
- **`stmicroelectronics.stm32-vscode-extension`** - the top-level STM32 extension that bundles and coordinates the `stm32cube-ide-*` set above.
- **`eclipse-cdt.memory-inspector`** - live memory view during embedded debugging, reading raw memory at a given address while a debug session is attached.
- **`eclipse-cdt.serial-monitor`** - a serial port monitor built into VS Code, for reading UART output from a connected board without a separate terminal tool.
- **`llvm-vs-code-extensions.lldb-dap`** - LLDB debugging via the Debug Adapter Protocol, an alternative debugger backend to GDB for native code.
- **`platformio.platformio-ide`** - PlatformIO's embedded development platform (build systems, board definitions, library management) for embedded projects outside the STM32Cube ecosystem.
- **`wokwi.wokwi-vscode`** - Wokwi's embedded hardware simulator, runs and debugs microcontroller firmware against a simulated board without real hardware attached.
- **`marus25.cortex-debug`** - ARM Cortex-M debugging (register/peripheral views, RTOS awareness, SVD-based memory maps). Added because the `stm32cube-ide-*` set contributes no VS Code commands of its own, this is the extension that actually gives the embedded workflow a bindable debug command.
- **`mcu-debug.peripheral-viewer`**, **`mcu-debug.memory-view`**, **`mcu-debug.rtos-views`** and **`mcu-debug.debug-tracker-vscode`** - installed automatically as Cortex-Debug's own dependencies, provide the peripheral register view, live memory inspection, RTOS thread view and the debug session tracker it builds on.

## Python and Jupyter

- **`ms-python.python`** - Microsoft's core Python extension: interpreter selection, running and debugging scripts.
- **`ms-python.vscode-pylance`** - the actual language server behind Python IntelliSense, type checking and autocomplete.
- **`ms-python.debugpy`** - the debugger `ms-python.python` uses under the hood.
- **`ms-python.black-formatter`** - runs the `black` formatter on save/format-document.
- **`ms-python.flake8`** - `flake8` linting inline as diagnostics.
- **`ms-python.vscode-python-envs`** - virtual environment discovery and switching.
- **`ms-toolsai.jupyter`** - Jupyter notebook support directly in the editor (`.ipynb` files, cell execution).
- **`ms-toolsai.jupyter-keymap`** - classic Jupyter Notebook keybindings inside VS Code's notebook editor.
- **`ms-toolsai.jupyter-renderers`** - rich output rendering (plots, HTML, LaTeX) inside notebook cells.
- **`ms-toolsai.vscode-jupyter-cell-tags`** and **`vscode-jupyter-slideshow`** - cell metadata tagging and slideshow-mode support for notebooks.

## Java and JVM

- **`redhat.java`** - Red Hat's Java language server (IntelliSense, refactoring, navigation).
- **`vscjava.vscode-java-pack`** - Microsoft's Java extension pack, bundles the extensions below into one install.
- **`vscjava.vscode-java-debug`** - Java debugging support.
- **`vscjava.vscode-java-test`** - running and debugging JUnit/TestNG tests from the editor.
- **`vscjava.vscode-java-dependency`** - a project/dependency explorer view for Java projects.
- **`vscjava.vscode-maven`** and **`vscjava.vscode-gradle`** - Maven and Gradle build tool integration (running goals/tasks, dependency trees) for the two dominant JVM build systems.
- **`oracle.oracle-java`** - Oracle's own Java tooling, kept alongside Red Hat's for cases where Oracle-specific JDK features or diagnostics are needed.

## .NET and C# tooling

- **`ms-dotnettools.csdevkit`** - the official C# Dev Kit: solution explorer, test runner, project management.
- **`ms-dotnettools.csharp`** - the underlying C# language server (IntelliSense, debugging) the Dev Kit builds on.
- **`ms-dotnettools.vscode-dotnet-runtime`** - manages the .NET runtime versions other extensions in this group depend on.

## Web and JavaScript

- **`bradlc.vscode-tailwindcss`** - Tailwind CSS class autocomplete, linting and hover previews.
- **`dbaeumer.vscode-eslint`** - ESLint diagnostics inline, JavaScript/TypeScript linting.
- **`esbenp.prettier-vscode`** - Prettier formatting on save/format-document.
- **`ecmel.vscode-html-css`** - CSS class/id autocomplete inside HTML based on the project's actual stylesheets.
- **`ritwickdey.liveserver`** - a local dev server with live reload for static HTML/CSS/JS, no build tool required.
- **`ms-vscode.vscode-typescript-next`** - nightly TypeScript builds, for testing against upcoming TypeScript features before they ship in VS Code's bundled version.
- **`christian-kohler.npm-intellisense`** - autocompletes npm package names in `import`/`require` statements.
- **`christian-kohler.path-intellisense`** - autocompletes local file paths in `import`/`require` statements, the same author's companion extension to `npm-intellisense` above.

## Go, PHP, Swift, PowerShell

- **`golang.go`** - the official Go extension: IntelliSense, debugging, formatting, `go vet`/`go test` integration.
- **`bmewburn.vscode-intelephense-client`** - PHP language server (IntelliSense, go-to-definition) via Intelephense.
- **`swiftlang.swift-vscode`** - the official Swift extension: language server, debugging, Swift Package Manager integration.
- **`ms-vscode.powershell`** - PowerShell language support and an integrated PowerShell debugger.

## Databases

- **`ms-mssql.mssql`** - SQL Server connection management, query execution and results grids.
- **`ms-mssql.data-workspace-vscode`** - workspace-level organisation for multiple database projects.
- **`ms-mssql.sql-database-projects-vscode`** - SQL Server Data Tools-style database projects (schema-as-code, builds a `.dacpac`).
- **`ms-mssql.sql-bindings-vscode`** - generates Azure Functions SQL bindings from a database project.
- **`cweijan.vscode-mysql-client2`** - a MySQL/MariaDB client: connections, query execution, table browsing.
- **`cweijan.dbclient-jdbc`** - JDBC driver support the MySQL client (and other cweijan database extensions) depend on for less common database engines.
- **`mtxr.sqltools`** - a general-purpose SQL client supporting multiple database engines through separate driver extensions.
- **`formulahendry.vscode-mysql`** - a lighter-weight alternative MySQL client for quick queries without a full connection profile.
- **`mechatroner.rainbow-csv`** - colour-codes CSV/TSV columns and adds a query language for filtering them, pairs with the database clients above for viewing exported data.

## Git and GitHub

- **`eamodio.gitlens`** - blame annotations, commit history exploration, file and line history, a much deeper Git view than VS Code's built-in one.
- **`github.vscode-pull-request-github`** - review, comment on and merge GitHub pull requests without leaving the editor.
- **`github.vscode-github-actions`** - view workflow runs and logs. Also gets YAML IntelliSense for `.github/workflows/` files.

## Containers and cloud

- **`ms-azuretools.vscode-containers`** - Docker and container management: building images, running containers, viewing logs, directly from the editor.
- **`ms-edgedevtools.vscode-edge-devtools`** - Edge DevTools embedded in VS Code, for inspecting and debugging a webpage without switching to the browser.

## Themes

- **`zacess.zacess-themes`** - the eight Zacess colour themes. `Zacess Deep Contrast Dark` is the theme `settings.json` sets; the other seven, `Zacess Deep Contrast Light` among them, are in the theme picker.

## Editor quality of life

- **`redhat.vscode-yaml`** - YAML language support (schema validation, autocomplete), used for CI workflow files and any project YAML.
- **`gruntfuggly.todo-tree`** - collects every `TODO`/`FIXME`-style comment across a project into one panel, complements the TODO snippets in `global.code-snippets`.
- **`usernamehw.errorlens`** - shows lint and compiler errors inline at the end of the offending line, instead of only in the Problems panel.
- **`streetsidesoftware.code-spell-checker`** - spell-checks code, comments and prose, catching typos in identifiers and documentation alike.
- **`editorconfig.editorconfig`** - honours a project's `.editorconfig` file for indentation, line endings and charset, overriding VS Code's own defaults per-project.
- **`vscodevim.vim`** - Vim keybindings and modal editing inside VS Code.

## Formatting and viewing niceties

- **`davidanson.vscode-markdownlint`** - lints markdown files, the same linter this folder's own CI runs.
- **`shd101wyy.markdown-preview-enhanced`** - a richer markdown preview than VS Code's built-in one (diagrams, math, presentation export).
- **`bierner.markdown-mermaid`** - draws Mermaid diagrams (flowcharts, sequence diagrams and so on) in VS Code's built-in markdown preview, so diagrams in notes and READMEs show up without leaving the editor.
- **`tomoki1207.pdf`** - opens and renders PDF files directly inside a VS Code tab.
- **`zainchen.json`** - additional JSON formatting and validation niceties.
- **`timheuer.jsondbg`** - a JSON debugging and inspection helper for exploring large or deeply nested JSON structures.
- **`dadroit.dadroit-json-generator`** - generates realistic sample JSON from a schema or example, useful for test fixtures.
- **`adpyke.codesnap`** - exports a selection of code as a shareable, styled image.
- **`tamasfe.even-better-toml`** - TOML language support (validation, autocomplete, schema), used for files like `pyproject.toml` from the Python tooling above.

## Presence and time tracking

- **`icrawl.discord-vscode`** and **`leonardssh.vscord`** - two different Discord Rich Presence integrations, showing what's being worked on as a Discord status. Both show the file type only (for example "Editing a TypeScript file") and never a file, workspace or repository name.
- **`wakatime.vscode-wakatime`** - automatic coding time tracking and statistics via WakaTime.
