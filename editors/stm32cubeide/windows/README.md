# windows

Tested with STM32CubeIDE 2.1.1 and 2.2.0, which install to `C:\ST\STM32CubeIDE_<version>` with the workspace at `%USERPROFILE%\STM32CubeIDE\workspace_<version>`. The settings match macOS, apart from the font size: GeistMono Nerd Font at 14 points from `prefs/` (written `GeistMono NF` and `GeistMono NFM`, the names Windows knows it by), which matches 18 on macOS on screen.

| File | What it is |
| --- | --- |
| [`apply.ps1`](apply.ps1) | Merges [`..\shared\prefs\`](../shared/prefs/), [`prefs\`](prefs/) and a theme into a workspace, the PowerShell version of `apply.sh` |
| [`prefs/org.eclipse.ui.workbench.prefs`](prefs/org.eclipse.ui.workbench.prefs) | The editor, C editor and Terminal font at 14 points |
| [`plugins.txt`](plugins.txt) | Plugins wanted, one per line with its update site |

## STM32CubeIDE itself

Download **STM32CubeIDE-Win** from [st.com](https://www.st.com/en/development-tools/stm32cubeide.html) (a free ST account is needed) and run the installer. It installs the ST-LINK drivers alongside the IDE. Start it once so it creates the workspace, then quit it.

Install the plugins in [`plugins.txt`](plugins.txt) through **Help > Install New Software** with each update site.

> [!NOTE]
> STM32CubeIDE finds serial ports by running `powershell.exe -Command`, so a Windows PowerShell profile that prints anything shows up in its port list. Keep a profile silent when it is not run interactively.

## Apply

```powershell
pwsh -File "$HOME\dev\github\repos\dotfiles\editors\stm32cubeide\windows\apply.ps1"                        # the newest workspace_<version>
pwsh -File "$HOME\dev\github\repos\dotfiles\editors\stm32cubeide\windows\apply.ps1" -Workspace D:\other-ws  # any other workspace
pwsh -File "$HOME\dev\github\repos\dotfiles\editors\stm32cubeide\windows\apply.ps1" -Theme cream            # another Zacess theme
```

> [!NOTE]
> Run it from PowerShell 7 (`pwsh`). Windows PowerShell 5.1 refuses to run any script under its default execution policy.
