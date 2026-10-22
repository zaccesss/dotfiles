# setup

One command per operating system that turns a fresh machine into a full development machine, plus
the captured desktop settings those commands apply. Each bootstrap clones this repository once and
links every config from its folder, so an edit here reaches the machine straight away.

| Folder | What it is | Platforms |
| --- | --- | --- |
| [mac-bootstrap](mac-bootstrap) | Xcode tools, Homebrew and the Brewfile, the shell profile, tool configs, toolchains and the captured macOS settings | macOS 14 or later |
| [linux-bootstrap](linux-bootstrap) | Language toolchains, embedded and electronics tools, cloud and DevOps tools and Git, with an opt-in `configs` extra for the profile and tool configs | Ubuntu 24.04 and 26.04, including WSL2 and VMs |
| [windows-bootstrap](windows-bootstrap) | Every winget package, the PowerShell profile, Git and SSH, tool configs, VS Code extensions, the captured settings and WSL2 | Windows 11 |
| [defaults](defaults) | Desktop preference scripts driven by one shared preference model, captured on one machine and replayed on the next | macOS, Linux (GNOME) and Windows |

The three bootstraps are licensed under the Apache License 2.0, each with its own `LICENSE` and
`NOTICE.md`. Everything else in this repository is MIT. See the [root README](../README.md#licence).
