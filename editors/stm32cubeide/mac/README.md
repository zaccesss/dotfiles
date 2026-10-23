# mac

STM32CubeIDE on macOS supports STM32 microcontrollers; ST's MPU (Linux-capable) boards need Windows or Linux.

| File | What it is |
| --- | --- |
| [`apply.sh`](apply.sh) | Merges [`../shared/prefs/`](../shared/prefs/), [`prefs/`](prefs/) and a theme into a workspace. Identical to [`../linux/apply.sh`](../linux/apply.sh) |
| [`prefs/org.eclipse.ui.workbench.prefs`](prefs/org.eclipse.ui.workbench.prefs) | The editor, C editor and Terminal font at 18 points |
| [`plugins.txt`](plugins.txt) | Plugins wanted, one per line with its update site |

## STM32CubeIDE itself

Download **STM32CubeIDE-Mac** from [st.com](https://www.st.com/en/development-tools/stm32cubeide.html) (a free ST account is needed) and follow the macOS section of ST's [installation guide (UM2609)](https://www.st.com/resource/en/user_manual/um2609-stm32cubeide-installation-guide-stmicroelectronics.pdf), which also installs the ST-LINK server the debugger needs. Start STM32CubeIDE once so it creates the workspace, then quit it.

Install the plugins in [`plugins.txt`](plugins.txt) through **Help > Install New Software** with each update site.

## Apply

```bash
~/dev/github/repos/dotfiles/editors/stm32cubeide/mac/apply.sh                         # the newest workspace_<version>
~/dev/github/repos/dotfiles/editors/stm32cubeide/mac/apply.sh ~/STM32CubeIDE/other-ws # any other workspace
~/dev/github/repos/dotfiles/editors/stm32cubeide/mac/apply.sh --theme cream           # another Zacess theme
```
