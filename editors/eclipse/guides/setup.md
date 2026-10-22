# Setup

## 1. Install the JDK and Eclipse

The preferences target Java SE 25, so install Eclipse Temurin 25.

macOS (Homebrew):

```bash
brew install --cask temurin@25
brew install --cask eclipse-java
```

Windows:

```powershell
winget install --id EclipseAdoptium.Temurin.25.JDK --exact
```

Linux (Fedora, from Adoptium's own RPM repository as its
[Linux install page](https://adoptium.net/installation/linux/) gives it):

```bash
sudo tee /etc/yum.repos.d/adoptium.repo > /dev/null <<'REPO'
[Adoptium]
name=Adoptium
baseurl=https://packages.adoptium.net/artifactory/rpm/fedora/$releasever/$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.adoptium.net/artifactory/api/gpg/key/public
REPO
sudo dnf install temurin-25-jdk
```

On Windows and Linux, download **Eclipse IDE for Java Developers** from
[eclipse.org/downloads](https://www.eclipse.org/downloads/packages/).

## 2. Open the workspace once

Start Eclipse, choose the workspace folder and quit it again. That creates the workspace's
`.metadata` folder, which the merge script needs. It refuses to run on a folder without one, so a
typo never creates a stray workspace.

| Platform | Default workspace |
| --- | --- |
| macOS | `~/eclipse-workspace` |
| Linux | `~/eclipse-workspace` |
| Windows | `%USERPROFILE%\eclipse-workspace` |

## 3. Clone

```bash
git clone https://github.com/zaccesss/dotfiles.git ~/dev/github/repos/dotfiles
```

## 4. Merge the preferences

Quit Eclipse first, then on macOS or Linux:

```bash
~/dev/github/repos/dotfiles/editors/eclipse/apply.sh                 # the default workspace
~/dev/github/repos/dotfiles/editors/eclipse/apply.sh ~/some-other-ws # any other workspace
```

On Windows, from PowerShell 7:

```powershell
pwsh -File "$HOME\dev\github\repos\dotfiles\editors\eclipse\apply.ps1"
pwsh -File "$HOME\dev\github\repos\dotfiles\editors\eclipse\apply.ps1" -Workspace D:\some-other-ws
```

> [!NOTE]
> Windows PowerShell 5.1 refuses to run any script under its default execution policy, so use
> PowerShell 7 (`winget install Microsoft.PowerShell`).

The script:

1. refuses to run while a process called `eclipse` is open
2. for each fragment in [`prefs/`](../prefs/), replaces the matching key in the workspace file or
   adds it at the end, leaving every other line as it was
3. prints each key as `added`, `changed` or `unchanged`

Running it again changes nothing and prints every key as `unchanged`. Nothing is backed up: the
repo holds every value the script writes.

> [!WARNING]
> The key bindings are stored as one value, so merging them replaces any binding already added by
> hand in that workspace. Copy any binding worth keeping into the fragment first.

## 5. Set the editor font

The scripts leave the font alone, since Eclipse stores it in a platform-specific form. Set it once:

1. Open **Window > Preferences** (**Eclipse > Settings** on macOS), then
   **General > Appearance > Colors and Fonts**.
2. Expand **Basic**, select **Text Font** and click **Edit**.
3. Pick a monospaced font at a size that reads comfortably and click **Apply and Close**.

The Java editor font follows **Text Font** unless it has been changed on its own.

The Terminal view has its own font. A Nerd Font makes the symbols a themed prompt uses (branch,
status and battery icons) draw there. GeistMono Nerd Font is a free choice under the SIL Open Font
License, from the [Nerd Fonts releases](https://github.com/ryanoasis/nerd-fonts/releases). Install
it, then in the same **Colors and Fonts** page expand **Terminal**, select **Terminal Console Font**
and pick it.

## 6. Pick the default JRE

Open **Java > Installed JREs** in the preferences. Tick the Temurin 25 entry. If it is missing,
click **Search** and point it at the JDK folder.

## 7. Install the plugins

For each line in [`plugins.txt`](../plugins.txt), open **Help > Install New Software**, paste the
update site into **Work with** and follow the wizard. Or open **Help > Eclipse Marketplace** and
search for the plugin's name.

## Verify it worked

1. `Cmd+P` (`Ctrl+P` on Windows and Linux) opens **Open Resource**.
2. `Cmd+Shift+P` (`Ctrl+Shift+P`) opens quick access, also inside a Java file.
3. **Java > Compiler** in the preferences shows compliance level 25 with **Use '--release' option**
   ticked.
4. **General > Editors > Autosave** shows autosave turned on with an interval of 20 seconds.

## Updating after a change to this folder

```bash
cd ~/dev/github/repos/dotfiles/editors/eclipse
git pull
```

Then quit Eclipse and repeat step 4.
