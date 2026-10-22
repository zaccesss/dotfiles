# Setup

## 1. Install STM32CubeIDE

Each platform's `README.md` has the steps: [mac](../mac/README.md), [linux](../linux/README.md), [windows](../windows/README.md). ST publishes STM32CubeIDE for Windows, macOS and Linux (a generic installer, an RPM and a Debian package) on [st.com](https://www.st.com/en/development-tools/stm32cubeide.html). Downloading needs a free ST account.

## 2. Open the workspace once

Start STM32CubeIDE, accept or choose the workspace folder and quit it again. That creates the workspace's `.metadata` folder, which the merge script needs. It refuses to run on a folder without one, so a typo never creates a stray workspace.

STM32CubeIDE names its default workspace after its own version, so it changes with each major update:

| Platform | Default workspace |
| --- | --- |
| macOS | `~/STM32CubeIDE/workspace_<version>` |
| Linux | `~/STM32CubeIDE/workspace_<version>` |
| Windows | `%USERPROFILE%\STM32CubeIDE\workspace_<version>` |

With no workspace given, the scripts pick the newest of these that has a `.metadata` folder.

## 3. Clone

```bash
git clone https://github.com/zaccesss/dotfiles.git ~/dev/github/repos/dotfiles
```

## 4. Merge the preferences

Quit STM32CubeIDE first, then on macOS or Linux:

```bash
~/dev/github/repos/dotfiles/editors/stm32cubeide/<platform>/apply.sh                         # the newest default workspace
~/dev/github/repos/dotfiles/editors/stm32cubeide/<platform>/apply.sh ~/STM32CubeIDE/other-ws # any other workspace
~/dev/github/repos/dotfiles/editors/stm32cubeide/<platform>/apply.sh --theme light           # another Zacess theme
```

Replace `<platform>` with `mac` or `linux`. On Windows, from PowerShell 7:

```powershell
pwsh -File "$HOME\dev\github\repos\dotfiles\editors\stm32cubeide\windows\apply.ps1"
pwsh -File "$HOME\dev\github\repos\dotfiles\editors\stm32cubeide\windows\apply.ps1" -Workspace D:\other-ws -Theme light
```

The script:

1. refuses to run while a process called `stm32cubeide` is open
2. for each fragment in [`shared/prefs/`](../shared/prefs/), then the platform's own `prefs/` folder, replaces the matching key in the workspace file or adds it at the end, leaving every other line as it was
3. merges the chosen theme the same way and sets the matching Light or Dark workbench theme
4. prints each key as `added`, `changed` or `unchanged`

Running it again changes nothing and prints every key as `unchanged`. Nothing is backed up: the folder holds every value the script writes.

> [!TIP]
> To go back to STM32CubeIDE's own colours, open **Window > Preferences > C/C++ > Editor > Syntax Coloring** and **General > Appearance > Colors and Fonts** and click **Restore Defaults**.

## 5. The fonts

The apply scripts set the text font and the C/C++ editor font to GeistMono Nerd Font and the Terminal font to GeistMono Nerd Font Mono from each platform's `prefs/` overlay: 18 points on the Mac, 14 on Windows and Linux. Install the font first (the Windows and Linux bootstraps do, Homebrew on the Mac). To change it later, open **Window > Preferences > General > Appearance > Colors and Fonts**, expand **C/C++** or **Basic** and click **Edit**.

## Verify it worked

1. `Ctrl+P` (`Cmd+P` on the Mac) opens **Open Resource**.
2. In a C file, `F12` opens the declaration under the cursor and `F2` renames it.
3. **Window > Preferences > C/C++ > Editor > Syntax Coloring** shows the Zacess colours. A macro such as `__HAL_RCC_GPIOA_CLK_ENABLE` is coloured apart from a function call such as `HAL_GPIO_TogglePin`.
4. **General > Editors > Autosave** shows autosave turned on with an interval of 20 seconds.

## Updating after a change to this folder

```bash
cd ~/dev/github/repos/dotfiles/editors/stm32cubeide
git pull
```

Then quit STM32CubeIDE and repeat step 4.

> [!NOTE]
> Changing a tracked preference inside STM32CubeIDE only changes that workspace. Copy the new line from the workspace's `.prefs` file into the matching fragment so the folder never falls behind the machine.
