# installs the Zacess theme file into Zed's themes folder and sets the theme in settings.json.
# usage: .\apply.ps1 [-Theme <theme>] [-ConfigDir <folder>]
#   (the config folder defaults to %APPDATA%\Zed)
#
# -Theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark.
#
# the theme file is the one Zacess Themes ships for Zed, kept in ..\shared\themes while the
# extension store still has an older version; once the installed extension reaches the pinned
# version the local copy is removed so the themes never load twice. the tracked settings.json is
# linked or copied into place by hand, never replaced here: only its theme block
# changes, swapped in the text itself so the comments and layout stay as they were.
#
# Zed reloads its settings and themes while it runs, so unlike the other apply scripts this one
# never checks whether Zed is open.
param(
    [string]$Theme = 'deep-dark',
    [string]$ConfigDir = (Join-Path $env:APPDATA 'Zed')
)

$ErrorActionPreference = 'Stop'
$shared = Join-Path $PSScriptRoot '..\shared'

$themes = @(
    @{ Id = 'deep-contrast-dark'; Short = 'deep-dark'; Name = 'Zacess Deep Contrast Dark'; Dark = $true }
    @{ Id = 'deep-contrast-light'; Short = 'deep-light'; Name = 'Zacess Deep Contrast Light'; Dark = $false }
    @{ Id = 'high-contrast-dark'; Short = 'hc-dark'; Name = 'Zacess High Contrast Dark'; Dark = $true }
    @{ Id = 'high-contrast-light'; Short = 'hc-light'; Name = 'Zacess High Contrast Light'; Dark = $false }
    @{ Id = 'dark'; Short = 'dark'; Name = 'Zacess Dark'; Dark = $true }
    @{ Id = 'light'; Short = 'light'; Name = 'Zacess Light'; Dark = $false }
    @{ Id = 'cream'; Short = 'cream'; Name = 'Zacess Cream'; Dark = $false }
    @{ Id = 'yellow-on-black'; Short = 'yellow'; Name = 'Zacess Yellow on Black'; Dark = $true }
)
$key = ($Theme.Trim().ToLowerInvariant() -replace ' ', '-') -replace '^zacess-', ''
$wanted = $themes | Where-Object { $_.Id -eq $key -or $_.Short -eq $key } | Select-Object -First 1
if (-not $wanted) {
    [Console]::Error.WriteLine("Unknown theme: $Theme")
    [Console]::Error.WriteLine('Pick one of deep-dark, deep-light, hc-dark, hc-light, dark, light, cream or yellow.')
    exit 1
}

$exe = Join-Path $env:LOCALAPPDATA 'Programs\Zed\Zed.exe'
if (-not ((Test-Path $ConfigDir) -or (Test-Path $exe) -or (Get-Command zed -ErrorAction SilentlyContinue))) {
    Write-Output 'Zed is not installed, skipped.'
    Write-Output 'Install Zed, start it once, then run this again or pass -ConfigDir.'
    exit 0
}
Write-Output "Settings: $ConfigDir"

# installed extensions live in Zed's local data folder, not beside its settings
$package = Get-Content (Join-Path $shared 'theme-package.json') -Raw | ConvertFrom-Json
$manifest = Join-Path $env:LOCALAPPDATA "Zed\extensions\installed\$($package.name)\extension.toml"
$extension = if (Test-Path $manifest) { [regex]::Match((Get-Content $manifest -Raw), '(?m)^version\s*=\s*"([^"]+)"').Groups[1].Value }
$covered = $extension -and ([version]$extension -ge [version]$package.version)

$themesDir = Join-Path $ConfigDir 'themes'
foreach ($source in Get-ChildItem (Join-Path $shared 'themes') -Filter *.json | Sort-Object Name) {
    $target = Join-Path $themesDir $source.Name
    if ($covered) {
        # the extension now carries these themes, so a second copy would list each theme twice
        if (Test-Path $target) {
            Remove-Item $target -Force
            Write-Output "  removed    themes  $($source.Name) (Zacess Themes $extension is installed as an extension)"
        } else {
            Write-Output "  unchanged  themes  $($source.Name) not needed (Zacess Themes $extension is installed as an extension)"
        }
        continue
    }
    $want = [IO.File]::ReadAllBytes($source.FullName)
    $status = if (-not (Test-Path $target)) { 'added    ' }
              elseif (-not [Linq.Enumerable]::SequenceEqual([IO.File]::ReadAllBytes($target), $want)) { 'changed  ' }
              else { 'unchanged' }
    if ($status -ne 'unchanged') {
        New-Item -ItemType Directory -Force $themesDir | Out-Null
        [IO.File]::WriteAllBytes($target, $want)
    }
    Write-Output "  $status  themes  $($source.Name)"
}

# the theme block the same way zt sets it: a fixed theme keeps the other half of the pair, so
# switching back to following the system needs no second step
$settingsFile = Join-Path $ConfigDir 'settings.json'
if (Test-Path $settingsFile) {
    $text = [IO.File]::ReadAllText($settingsFile)
    # Zed's file allows // comments and trailing commas, which ConvertFrom-Json does not
    $plain = [regex]::Replace(($text -replace '(?m)^\s*//.*$', ''), ',(\s*[}\]])', '$1')
    $current = ($plain | ConvertFrom-Json).theme
    $pair = if ($current -is [pscustomobject]) { $current } else { [pscustomobject]@{} }
    $light = if ($wanted.Dark) { if ($pair.PSObject.Properties['light']) { $pair.light } else { 'Zacess Deep Contrast Light' } } else { $wanted.Name }
    $dark = if ($wanted.Dark) { $wanted.Name } else { if ($pair.PSObject.Properties['dark']) { $pair.dark } else { 'Zacess Deep Contrast Dark' } }
    $mode = if ($wanted.Dark) { 'dark' } else { 'light' }
    $same = ($current -is [pscustomobject]) -and $current.PSObject.Properties['mode'] -and $current.mode -eq $mode -and $current.light -eq $light -and $current.dark -eq $dark
    if ($same) {
        Write-Output '  unchanged  settings.json  theme'
    } else {
        $value = '(?:"(?:[^"\\]|\\.)*"|true|false|null|-?\d+(?:\.\d+)?|\{[^{}]*\})'
        $match = [regex]::Match($text, '("theme"\s*:\s*)' + $value)
        $entries = @("`"mode`": `"$mode`"", "`"light`": `"$light`"", "`"dark`": `"$dark`"")
        if ($match.Success) {
            $old = $match.Value.Substring($match.Groups[1].Length)
            if ($old.Contains("`n")) {
                # an object already spread over lines keeps that shape and its trailing comma, so a
                # linked settings file only changes where a value did
                $lineStart = $text.LastIndexOf("`n", $match.Index) + 1
                $pad = [regex]::Match($text.Substring($lineStart), '^[ \t]*').Value
                $inside = [regex]::Match($old, '\n([ \t]+)\S')
                $step = if ($inside.Success) { $inside.Groups[1].Value } else { $pad + '  ' }
                $trailing = if ($old -match ',\s*}\s*$') { ',' } else { '' }
                $rendered = "{`n" + (($entries | ForEach-Object { "$step$_" }) -join ",`n") + $trailing + "`n$pad}"
            } else {
                $rendered = '{ ' + ($entries -join ', ') + ' }'
            }
            $new = $text.Substring(0, $match.Index) + $match.Groups[1].Value + $rendered + $text.Substring($match.Index + $match.Length)
        } else {
            # a new key goes first, after the opening brace, with the file's own indent
            $indent = [regex]::Match($text, '\n([ \t]+)"')
            $pad = if ($indent.Success) { $indent.Groups[1].Value } else { '  ' }
            $brace = $text.IndexOf('{')
            $new = $text.Substring(0, $brace + 1) + "`n$pad`"theme`": { " + ($entries -join ', ') + " },"  + $text.Substring($brace + 1)
        }
        # the result is parsed before it is saved
        $null = [regex]::Replace(($new -replace '(?m)^\s*//.*$', ''), ',(\s*[}\]])', '$1') | ConvertFrom-Json
        [IO.File]::WriteAllText($settingsFile, $new, (New-Object Text.UTF8Encoding $false))
        Write-Output '  changed    settings.json  theme'
    }
} else {
    Write-Output "  skipped    settings.json  not here yet: link or copy editors\zed\settings.json there (see the README)"
}

Write-Output "Theme: $($wanted.Name)"
Write-Output 'Done. Zed reloads its settings and themes while it runs, so nothing needs restarting.'
