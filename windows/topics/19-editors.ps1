# =============================================================================
# Editor and IDE launchers - Windows PowerShell
# =============================================================================

function e  { code . }
function ec { code @args }

function extls      { code --list-extensions }
function extinstall { param($Ext) code --install-extension $Ext }
function extrm      { param($Ext) code --uninstall-extension $Ext }

function extdump {
    param([string]$File = "extensions.txt")
    code --list-extensions | Out-File $File
    Write-Host "Saved to $File" -ForegroundColor Green
}

function extrestore {
    param([string]$File = "extensions.txt")
    if (-not (Test-Path $File)) { Write-Host "File not found: $File"; return }
    Get-Content $File | ForEach-Object { code --install-extension $_ }
}

# Cursor - AI-native editor, a VS Code fork that accepts the same CLI flags
function cursor { param($P = ".") cursor.exe $P }

# JetBrains IDE launchers - Toolbox installs scripts to
# %APPDATA%\JetBrains\Toolbox\scripts\ - ensure that's on PATH
function _jb_open {
    param([string]$Cmd, [string]$Path = ".")
    if (Get-Command $Cmd -ErrorAction SilentlyContinue) {
        & $Cmd $Path
    } else {
        Write-Host "$Cmd not found - enable shell scripts in JetBrains Toolbox settings"
    }
}

function idea     { param($P = ".") _jb_open "idea"     $P }
function pycharm  { param($P = ".") _jb_open "pycharm"  $P }
function webstorm { param($P = ".") _jb_open "webstorm" $P }
function goland   { param($P = ".") _jb_open "goland"   $P }
function clion    { param($P = ".") _jb_open "clion"    $P }
function rider    { param($P = ".") _jb_open "rider"    $P }
function phpstorm { param($P = ".") _jb_open "phpstorm" $P }
function datagrip { param($P = ".") _jb_open "datagrip" $P }
