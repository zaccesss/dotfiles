# New Device Setup Guide

Step-by-step walkthrough for setting up these dotfiles on a brand new machine. Follow the section for your platform from top to bottom.

---

## Contents

- [macOS](#macos)
- [Linux (Ubuntu / Debian)](#linux-ubuntu--debian)
- [WSL2 on Windows](#wsl2-on-windows)
- [Windows (native PowerShell)](#windows-native-powershell)

---

## macOS

### 1 - Install Xcode Command Line Tools

Required for git, compilers and Homebrew.

```bash
xcode-select --install
```

### 2 - Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the "Next steps" printed after the install to add Homebrew to your PATH.

### 3 - Install core tools

```bash
brew install git curl jq gh
gh auth login
```

### 4 - Clone this repo

Clone into wherever you keep your projects:

```bash
# replace /path/to/your/projects with your preferred location
git clone https://github.com/zaccesss/dotfiles /path/to/your/projects/dotfiles
cd /path/to/your/projects/dotfiles
```

### 5 - Apply the shell profile

```bash
cp mac/zshrc ~/.zshrc
source ~/.zshrc
```

The welcome banner confirms the profile loaded. Run `cmds` to see all available commands.

> [!NOTE]
> The profile uses `~/dev` as a convention for the base dev folder. Review [mac/topics/03-navigation.zsh](../mac/topics/03-navigation.zsh) and adjust the directory shortcuts to match your own folder layout before applying.

### 6 - Install VS Code

Download from [code.visualstudio.com](https://code.visualstudio.com). After installing, enable the `code` terminal command:

Press `Cmd+Shift+P` in VS Code, type "Shell Command: Install 'code' command in PATH" and run it.

### 7 - Set up the Starship prompt

`34-starship.zsh` is already in the profile and will be sourced automatically. You just need to install Starship and symlink the config:

```bash
brew install starship
mkdir -p ~/.config
ln -sf /path/to/your/projects/dotfiles/mac/starship.toml ~/.config/starship.toml
```

Open a new terminal tab. The prompt will show your current directory, git branch and language versions automatically.

### 8 - Install language runtimes

Install whichever runtimes you need:

```bash
brew install node python go rustup
```

For Ruby:

```bash
brew install rbenv
rbenv install 3.3.0 && rbenv global 3.3.0
```

---

## Linux (Ubuntu / Debian)

### 1 - Update and install core tools

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl jq build-essential
```

### 2 - Install GitHub CLI

```bash
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install -y gh
gh auth login
```

### 3 - Clone this repo

```bash
git clone https://github.com/zaccesss/dotfiles /path/to/your/projects/dotfiles
cd /path/to/your/projects/dotfiles
```

### 4 - Apply the shell profile

```bash
cp linux/bashrc ~/.bashrc
source ~/.bashrc
```

Run `cmds` to confirm the profile loaded.

> [!NOTE]
> The profile uses `~/dev` as a convention for the base dev folder. Review [linux/topics/03-navigation.sh](../linux/topics/03-navigation.sh) and adjust directory shortcuts to match your own folder layout before applying.

### 5 - Install VS Code

```bash
sudo snap install --classic code
```

Or download the `.deb` package from [code.visualstudio.com](https://code.visualstudio.com).

### 6 - Set up the Starship prompt

`34-starship.sh` is already in the profile and will be sourced automatically. You just need to install Starship and symlink the config:

```bash
curl -sS https://starship.rs/install.sh | sh
mkdir -p ~/.config
ln -sf /path/to/your/projects/dotfiles/linux/starship.toml ~/.config/starship.toml
```

Open a new terminal tab. The prompt will show your current directory, git branch and language versions automatically.

### 7 - Install language runtimes

```bash
sudo apt install -y python3 python3-pip golang nodejs npm
```

For Rust:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
```

---

## WSL2 on Windows

### 1 - Enable WSL2

Open PowerShell as Administrator:

```powershell
wsl --install
```

Reboot when prompted. This installs Ubuntu by default.

### 2 - Follow the Linux guide inside WSL2

Once inside the WSL2 Ubuntu terminal, follow the [Linux (Ubuntu / Debian)](#linux-ubuntu--debian) steps above. The Linux profile works inside WSL2 without modification.

### 3 - Windows Terminal (recommended)

Install Windows Terminal from the Microsoft Store for a better WSL2 experience. The Windows profile includes `wt-here` and `wt-split` for pane management.

---

## Windows (native PowerShell)

### 1 - Install PowerShell 7+

```powershell
winget install Microsoft.PowerShell
```

Restart and open PowerShell 7.

### 2 - Install core tools

```powershell
winget install Git.Git GitHub.cli Microsoft.VisualStudioCode
gh auth login
```

### 3 - Clone this repo

```powershell
git clone https://github.com/zaccesss/dotfiles C:\path\to\your\projects\dotfiles
Set-Location C:\path\to\your\projects\dotfiles
```

### 4 - Apply the PowerShell profile

```powershell
$dir = Split-Path $PROFILE
if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force }
Copy-Item windows\Microsoft.PowerShell_profile.ps1 $PROFILE -Force
```

Restart PowerShell. Run `cmds` to confirm the profile loaded.

> [!WARNING]
> If you see a script execution policy error, run this once before proceeding:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

> [!NOTE]
> The profile uses `C:\dev` as a convention for the base dev folder. Review [windows/topics/03-navigation.ps1](../windows/topics/03-navigation.ps1) and adjust the directory shortcuts to match your own folder layout before applying.

### 5 - Set up the Starship prompt

`34-starship.ps1` is already in the profile and will be sourced automatically. You just need to install Starship and symlink the config:

```powershell
winget install Starship.Starship
New-Item -ItemType Directory -Force -Path "$HOME\.config"
New-Item -ItemType SymbolicLink -Path "$HOME\.config\starship.toml" -Target "C:\path\to\your\projects\dotfiles\windows\starship.toml"
```

> [!NOTE]
> Creating a symlink on Windows requires either running PowerShell as Administrator or enabling Developer Mode in Settings → System → For developers.

Open a new terminal tab. The prompt will show your current directory, git branch and language versions automatically.

### 6 - Install language runtimes

```powershell
winget install OpenJS.NodeJS Python.Python.3 GoLang.Go Rustlang.Rustup
```
