# Plugin guide

What each plugin in the `plugins/` lists is. The IDE column uses IU for IntelliJ IDEA, PC for
PyCharm, WS for WebStorm, CL for CLion and DS for DataSpell.

## Languages and frameworks

| Plugin id | What it does | IDEs |
| --- | --- | --- |
| `org.jetbrains.plugins.go` | Go support: completion, debugging, `go vet` and `go test` | IU |
| `com.jetbrains.php` | PHP support | IU |
| `com.jetbrains.rust` | Rust support | CL |
| `org.jetbrains.plugins.vue` | Vue.js support | IU, PC, WS, CL |
| `PythonCore` | Python support, the Community Edition core | IU, WS, CL, DS |
| `Pythonid` | Python enhancements bundled with IntelliJ IDEA Ultimate | IU |
| `JavaScriptDebugger` | JavaScript debugging engine | WS, CL |
| `intellij.vitejs` | Vite support. Marketplace has no build for DataSpell 2026.1, see [setup.md](setup.md#2-install-the-plugins) | CL, DS |
| `intellij.prettierJS` | Prettier integration | CL |
| `ru.adelf.idea.dotenv` | `.env` file highlighting and key completion | all |

## Build systems, containers and cloud

| Plugin id | What it does | IDEs |
| --- | --- | --- |
| `com.intellij.cmake` | CMake project support | CL |
| `com.intellij.clion.meson` | Meson build system support | CL |
| `Docker` | Dockerfile and container support | CL |
| `com.intellij.kubernetes` | Kubernetes cluster and manifest support | WS, CL, DS |

## Version control

| Plugin id | What it does | IDEs |
| --- | --- | --- |
| `hg4idea` | Mercurial support | IU |
| `PerforceDirectPlugin` | Perforce support | IU |
| `Subversion` | Subversion support | IU |

## Editor feel and tooling

| Plugin id | What it does | IDEs |
| --- | --- | --- |
| `com.intellij.plugins.vscodekeymap` | Supplies the `VSCode OSX` and `VSCode` base keymaps that [`keymaps/`](../keymaps/) builds on | all |
| `com.markskelton.one-dark-theme` | The One Dark colour theme | IU, CL, DS |
| `com.zacess.themes` | The eight Zacess themes, each with its own editor scheme; Zacess Deep Contrast Dark is the one in use | all |
| `org.editorconfig.editorconfigjetbrains` | Honours a project's `.editorconfig` file | CL, DS |
| `com.jetbrains.performancePlugin` | JetBrains's internal performance testing and profiling tooling | PC, CL |

## Presence, tracking and learning

| Plugin id | What it does | IDEs |
| --- | --- | --- |
| `com.almightyalpaca.intellij.plugins.discord` | Discord Rich Presence, shows what is being worked on as a Discord status | all |
| `com.wakatime.intellij.plugin` | WakaTime coding time tracking | all |
| `org.hyperskill.academy` | Hyperskill learning platform integration | IU, PC, WS, CL |
| `com.jetbrains.edu` | JetBrains Academy learning integration | IU, PC, WS, CL |
