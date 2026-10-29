# sets up Zacess Games on Windows: puts the newest release binary in ~\.local\bin after checking it
# against its published checksum. Safe to run again: it only downloads when the installed version is
# older.
#
#   & apps\zacess-games\setup.ps1
#
# the bootstrap passes -Theme to every app script; the games follow the theme zt last set instead
param([string]$Theme)
$null = $Theme

$ErrorActionPreference = 'Stop'
$Repo = 'zacesshq/games'
$BinDir = Join-Path $HOME '.local\bin'
$env:PATH = "$BinDir;$env:PATH"

function Install-ZacessGame {
    if ($env:PROCESSOR_ARCHITECTURE -ne 'AMD64') {
        "No Zacess Games build for $env:PROCESSOR_ARCHITECTURE, skipped."
        return
    }
    $tag = (Invoke-RestMethod "https://api.github.com/repos/$Repo/releases/latest").tag_name
    $have = $null
    if (Get-Command zacess-games -ErrorAction SilentlyContinue) { $have = (-split (zacess-games --version))[1] }
    if ("v$have" -eq $tag) { "Zacess Games $have is up to date."; return }

    $work = Join-Path ([IO.Path]::GetTempPath()) "zacess-games-$([guid]::NewGuid())"
    New-Item -ItemType Directory -Path $work | Out-Null
    try {
        $archive = "zacess-games-$tag-x86_64-pc-windows-msvc.zip"
        "Installing Zacess Games $tag..."
        Invoke-WebRequest "https://github.com/$Repo/releases/download/$tag/$archive" -OutFile (Join-Path $work $archive)
        Invoke-WebRequest "https://github.com/$Repo/releases/download/$tag/$archive.sha256" -OutFile (Join-Path $work "$archive.sha256")
        $want = (-split (Get-Content (Join-Path $work "$archive.sha256") -Raw))[0].ToLower()
        $got = (Get-FileHash (Join-Path $work $archive) -Algorithm SHA256).Hash.ToLower()
        if ($want -ne $got) { throw 'The Zacess Games download does not match its checksum, so it was not installed.' }
        Expand-Archive (Join-Path $work $archive) -DestinationPath $work
        New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
        $exe = Get-ChildItem $work -Recurse -Filter zacess-games.exe | Select-Object -First 1
        Copy-Item $exe.FullName (Join-Path $BinDir 'zacess-games.exe') -Force
        "Installed $(zacess-games --version)"
    } finally {
        Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Install-ZacessGame
