# sets up Zacess Scenes on Windows: puts the newest release binary in ~\.local\bin after checking it
# against its published checksum, installs bacon for watch mode with cargo and links scenes.toml into
# %APPDATA%\zacess. Safe to run again.
#
#   & apps\zacess-scenes\setup.ps1          install or update, then link the config
#   & apps\zacess-scenes\setup.ps1 -Link    only link the config
#
# the bootstrap passes -Theme to every app script; Scenes follows the theme zt last set instead
param([switch]$Link, [string]$Theme)
$null = $Theme

$ErrorActionPreference = 'Stop'
$Repo = 'zacesshq/scenes'
$BinDir = Join-Path $HOME '.local\bin'
$ConfigDir = Join-Path $env:APPDATA 'zacess'
$env:PATH = "$BinDir;$HOME\.cargo\bin;$env:PATH"

function Set-ScenesConfig {
    New-Item -ItemType Directory -Force -Path (Join-Path $ConfigDir 'scenes') | Out-Null
    $target = Join-Path $ConfigDir 'scenes.toml'
    $source = Join-Path $PSScriptRoot 'scenes.toml'
    $item = Get-Item $target -ErrorAction SilentlyContinue
    if ($item -and -not $item.LinkType) {
        # a file made by hand goes to the Recycle Bin rather than being overwritten
        Add-Type -AssemblyName Microsoft.VisualBasic
        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($target, 'OnlyErrorDialogs', 'SendToRecycleBin')
        "Moved the old $target to the Recycle Bin."
    } elseif ($item) {
        Remove-Item $target
    }
    # a symbolic link needs Developer Mode or an elevated shell; a copy is the fallback
    try {
        New-Item -ItemType SymbolicLink -Path $target -Target $source -ErrorAction Stop | Out-Null
        "Linked $target"
    } catch {
        Copy-Item $source $target
        "Copied scenes.toml to $target (turn on Developer Mode to link it instead)"
    }
}

function Install-Scenes {
    if ($env:PROCESSOR_ARCHITECTURE -ne 'AMD64') {
        "No Zacess Scenes build for $env:PROCESSOR_ARCHITECTURE, skipped."
        return
    }
    $tag = (Invoke-RestMethod "https://api.github.com/repos/$Repo/releases/latest").tag_name
    $have = $null
    if (Get-Command zacess-scenes -ErrorAction SilentlyContinue) { $have = (-split (zacess-scenes --version))[1] }
    if ("v$have" -eq $tag) { "Zacess Scenes $have is up to date."; return }

    $work = Join-Path ([IO.Path]::GetTempPath()) "zacess-scenes-$([guid]::NewGuid())"
    New-Item -ItemType Directory -Path $work | Out-Null
    try {
        $archive = "zacess-scenes-$tag-x86_64-pc-windows-msvc.zip"
        "Installing Zacess Scenes $tag..."
        Invoke-WebRequest "https://github.com/$Repo/releases/download/$tag/$archive" -OutFile (Join-Path $work $archive)
        Invoke-WebRequest "https://github.com/$Repo/releases/download/$tag/$archive.sha256" -OutFile (Join-Path $work "$archive.sha256")
        $want = (-split (Get-Content (Join-Path $work "$archive.sha256") -Raw))[0].ToLower()
        $got = (Get-FileHash (Join-Path $work $archive) -Algorithm SHA256).Hash.ToLower()
        if ($want -ne $got) { throw 'The Zacess Scenes download does not match its checksum, so it was not installed.' }
        Expand-Archive (Join-Path $work $archive) -DestinationPath $work
        New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
        $exe = Get-ChildItem $work -Recurse -Filter zacess-scenes.exe | Select-Object -First 1
        Copy-Item $exe.FullName (Join-Path $BinDir 'zacess-scenes.exe') -Force
        "Installed $(zacess-scenes --version)"
    } finally {
        Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Install-Bacon {
    if (Get-Command bacon -ErrorAction SilentlyContinue) { "bacon is installed."; return }
    if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
        'cargo is not installed, so bacon (for zacess-scenes watch) was skipped.'
        return
    }
    cargo install --locked bacon
}

if (-not $Link) {
    Install-Scenes
    Install-Bacon
}
Set-ScenesConfig
