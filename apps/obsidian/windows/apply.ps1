# sets up Obsidian with the four Zacess themes in one vault, picks one look and opens that vault
# by default.
# usage: .\apply.ps1 [-Theme <theme>] [-Vault <vault folder>]
#   (the vault defaults to OBSIDIAN_VAULT, the same variable zt reads, then %USERPROFILE%\Obsidian\Vault,
#   a plain folder outside any cloud-synced one)
#
# -Theme picks one of the ten Zacess looks by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow, warm-dark, warm-light), id (deep-contrast-dark) or full
# name. the default is deep-dark. each look is one half of a community theme (Zacess, Zacess Cream, Zacess High Contrast
# or Zacess Deep Contrast) chosen by Obsidian's base colour scheme, so appearance.json gets both
# cssTheme and theme.
#
# in a synced vault the .obsidian folder travels with it, so the theme files and appearance.json
# are shared by every machine. obsidian.json, which says which vault opens, is this machine's own.
# only the keys this script owns change and nothing is backed up: this folder holds every value it
# writes.
param(
    [string]$Theme = 'deep-dark',
    [string]$Vault = $(if ($env:OBSIDIAN_VAULT) { $env:OBSIDIAN_VAULT } else { Join-Path $HOME 'Obsidian\Vault' })
)

$ErrorActionPreference = 'Stop'
$shared = Join-Path $PSScriptRoot '..\shared'

$themeNames = [ordered]@{
    'deep-dark' = 'Zacess Deep Contrast Dark'; 'deep-contrast-dark' = 'Zacess Deep Contrast Dark'
    'deep-light' = 'Zacess Deep Contrast Light'; 'deep-contrast-light' = 'Zacess Deep Contrast Light'
    'hc-dark' = 'Zacess High Contrast Dark'; 'high-contrast-dark' = 'Zacess High Contrast Dark'
    'hc-light' = 'Zacess High Contrast Light'; 'high-contrast-light' = 'Zacess High Contrast Light'
    'dark' = 'Zacess Dark'; 'light' = 'Zacess Light'; 'cream' = 'Zacess Cream'
    'yellow' = 'Zacess Yellow on Black'; 'yellow-on-black' = 'Zacess Yellow on Black'
    'warm-dark' = 'Zacess Warm Dark'; 'warm-light' = 'Zacess Warm Light'
}
$key = ($Theme.ToLowerInvariant() -replace '^zacess[ -]', '') -replace ' ', '-'
$name = $themeNames[$key]
if (-not $name) {
    [Console]::Error.WriteLine("Unknown theme: $Theme")
    [Console]::Error.WriteLine('Pick one of deep-dark, deep-light, hc-dark, hc-light, dark, light, cream, yellow, warm-dark or warm-light.')
    exit 1
}
$dot = Join-Path $Vault '.obsidian'
if (-not (Test-Path $dot)) {
    [Console]::Error.WriteLine("No Obsidian vault at $Vault (no .obsidian folder). Pass -Vault or set OBSIDIAN_VAULT.")
    exit 1
}
# Obsidian writes appearance.json and obsidian.json back while it runs
if (Get-Process -Name 'Obsidian' -ErrorAction SilentlyContinue) {
    [Console]::Error.WriteLine('Obsidian is running. Quit it first, then run this again.')
    exit 1
}
Write-Output "Vault: $Vault"
$utf8 = New-Object Text.UTF8Encoding $false

# a cloud sync client can leave the theme and plugin files online only. Obsidian then starts on
# another theme because it cannot read them, so .obsidian is kept on this device. on a folder
# that is not synced the attributes change nothing
attrib.exe +P -U "$dot\*" /S /D | Out-Null
attrib.exe +P -U $dot | Out-Null

function Merge-Json([string]$path, [hashtable]$want, [string]$label) {
    $raw = if (Test-Path $path) { [IO.File]::ReadAllText($path) } else { '{}' }
    $current = $raw | ConvertFrom-Json -AsHashtable
    foreach ($k in $want.Keys) {
        $old = if ($current.Contains($k)) { $current[$k] | ConvertTo-Json -Compress -Depth 10 } else { $null }
        $new = $want[$k] | ConvertTo-Json -Compress -Depth 10
        $status = if ($null -eq $old) { 'added    ' } elseif ($old -ceq $new) { 'unchanged' } else { 'changed  ' }
        Write-Output "  $status  $label  $k"
        $current[$k] = $want[$k]
    }
    $text = ($current | ConvertTo-Json -Depth 10) + "`n"
    if ($raw -cne $text -and (($raw | ConvertFrom-Json | ConvertTo-Json -Compress -Depth 10) -cne ($current | ConvertTo-Json -Compress -Depth 10))) {
        New-Item -ItemType Directory -Force (Split-Path $path) | Out-Null
        [IO.File]::WriteAllText($path, $text, $utf8)
    }
}

# the four pinned theme packages, each checked against its digest and unpacked into
# .obsidian\themes\<theme name>. every theme goes in, not only the chosen one, so switching looks
# later needs no download and Obsidian's theme picker lists all four
$packages = Get-Content (Join-Path $shared 'theme-package.json') -Raw | ConvertFrom-Json
foreach ($package in $packages.themes) {
    $themeDir = Join-Path $dot "themes\$($package.folder)"
    $download = Join-Path ([IO.Path]::GetTempPath()) "$($package.name)-$PID.zip"
    $unpack = Join-Path ([IO.Path]::GetTempPath()) "$($package.name)-$PID"
    try {
        Invoke-WebRequest -Uri $package.url -OutFile $download -UseBasicParsing
        if ((Get-FileHash $download -Algorithm SHA256).Hash -ne $package.sha256) {
            [Console]::Error.WriteLine("The $($package.folder) download does not match its pinned checksum, so nothing was installed from it")
            exit 1
        }
        Expand-Archive -LiteralPath $download -DestinationPath $unpack -Force
        New-Item -ItemType Directory -Force $themeDir | Out-Null
        foreach ($file in Get-ChildItem $unpack -File) {
            $dest = Join-Path $themeDir $file.Name
            $status = if (-not (Test-Path $dest)) { 'added    ' } elseif ((Get-FileHash $dest).Hash -eq (Get-FileHash $file.FullName).Hash) { 'unchanged' } else { 'changed  ' }
            if ($status -ne 'unchanged') { Copy-Item $file.FullName $dest -Force }
            Write-Output "  $status  themes\$($package.folder)  $($file.Name)"
        }
    } finally {
        Remove-Item $download, $unpack -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# the chosen look: the theme that carries it and its dark or light half
$choice = (Get-Content (Join-Path $shared 'themes.json') -Raw | ConvertFrom-Json).$name
$appearance = Get-Content (Join-Path $shared 'appearance.json') -Raw | ConvertFrom-Json -AsHashtable
$appearance['cssTheme'] = $choice.cssTheme
$appearance['theme'] = $choice.theme
Merge-Json (Join-Path $dot 'appearance.json') $appearance 'appearance.json'

# this machine's vault list: the vault is the one marked open, so Obsidian starts in it
$list = Join-Path $env:APPDATA 'obsidian\obsidian.json'
$raw = if (Test-Path $list) { [IO.File]::ReadAllText($list) } else { '{"vaults":{}}' }
$data = $raw | ConvertFrom-Json -AsHashtable
if (-not $data.Contains('vaults')) { $data['vaults'] = @{} }
$full = (Resolve-Path $Vault).Path
$id = $data['vaults'].Keys | Where-Object { $data['vaults'][$_]['path'] -eq $full } | Select-Object -First 1
$status = 'unchanged'
if (-not $id) {
    $id = -join ((1..16) | ForEach-Object { '{0:x}' -f (Get-Random -Maximum 16) })
    $data['vaults'][$id] = @{ path = $full; ts = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds() }
    $status = 'added    '
}
foreach ($other in @($data['vaults'].Keys)) {
    $open = ($other -eq $id)
    if ([bool]$data['vaults'][$other]['open'] -ne $open) {
        if ($status -eq 'unchanged') { $status = 'changed  ' }
        if ($open) { $data['vaults'][$other]['open'] = $true } else { $data['vaults'][$other].Remove('open') }
    }
}
Write-Output "  $status  obsidian.json  default vault"
if ($status -ne 'unchanged') {
    New-Item -ItemType Directory -Force (Split-Path $list) | Out-Null
    [IO.File]::WriteAllText($list, ($data | ConvertTo-Json -Depth 10) + "`n", $utf8)
}

Write-Output "Theme: $name"
Write-Output 'Done. Start Obsidian to pick up the changes.'
