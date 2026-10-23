# linux

For Fedora, Ubuntu and Debian. The script matches macOS, apart from the font size: GeistMono Nerd Font at 14 points from `prefs/`, which matches 18 on macOS on screen.

| File | What it is |
| --- | --- |
| [`apply.sh`](apply.sh) | Merges [`../shared/prefs/`](../shared/prefs/), [`prefs/`](prefs/) and a theme into a workspace. Identical to [`../mac/apply.sh`](../mac/apply.sh) |
| [`prefs/org.eclipse.ui.workbench.prefs`](prefs/org.eclipse.ui.workbench.prefs) | The editor, C editor and Terminal font at 14 points |
| [`plugins.txt`](plugins.txt) | Plugins wanted, one per line with its update site |

## STM32CubeIDE itself

ST publishes three Linux downloads on [st.com](https://www.st.com/en/development-tools/stm32cubeide.html) (a free ST account is needed): a generic installer (**STM32CubeIDE-Lnx**), an RPM bundle (**STM32CubeIDE-RPM**) and a Debian bundle (**STM32CubeIDE-DEB**). On Fedora use the RPM bundle: unzip it and run its installer script with `sudo`, which installs the IDE to `/opt/st` along with the ST-LINK udev rules and the ST-LINK server the debugger needs. On Ubuntu or Debian use the Debian bundle the same way. The steps for each are in ST's [installation guide (UM2609)](https://www.st.com/resource/en/user_manual/um2609-stm32cubeide-installation-guide-stmicroelectronics.pdf).

Start STM32CubeIDE once so it creates the workspace, then quit it. Unplugging and replugging the board after the install lets the udev rules give the ST-LINK its permissions.

The plugins in [`plugins.txt`](plugins.txt) install without opening the IDE. `/opt/st` belongs to root,
so the director runs with `sudo`. Save the command as a one-line script and run that, since a long
command pasted into a terminal can be split into lines and start the IDE as root instead:

```bash
sudo /opt/st/stm32cubeide_<version>/stm32cubeide -nosplash -application org.eclipse.equinox.p2.director -repository https://wakatime.com/eclipse/update-site/ -installIU com.wakatime.eclipse.feature.feature.group
```

## Apply

```bash
~/dev/github/repos/dotfiles/editors/stm32cubeide/linux/apply.sh                         # the newest workspace_<version>
~/dev/github/repos/dotfiles/editors/stm32cubeide/linux/apply.sh ~/STM32CubeIDE/other-ws # any other workspace
~/dev/github/repos/dotfiles/editors/stm32cubeide/linux/apply.sh --theme cream           # another Zacess theme
```
