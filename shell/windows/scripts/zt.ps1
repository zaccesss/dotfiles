# zt: switch every installed editor and terminal to one Zacess theme at once (Windows).
#
#   zt <theme>                 fix that theme everywhere and stop following the system
#   zt auto [dark] [light]     follow the Windows light and dark setting, Deep Contrast by default
#   zt list                    the eight themes and their short names
#   zt current                 the mode zt last set and what each tool is on now
#
# each tool is edited in place and only for its theme setting; a tool that is not installed is
# skipped. the JetBrains IDEs, Eclipse, STM32CubeIDE and the apps with their own apply script
# (Arduino IDE, Notepad++, Thonny, LTspice, Proteus, Zotero, Obsidian, MATLAB, KiCad, Vivado,
# Processing and Microchip Studio) are only changed while they are closed, since they write their
# settings back on exit. MATLAB and Microchip Studio are started briefly to apply a theme and
# closed again. scripts/zt.py is the macOS and Linux version; both keep the same state file
# format, which Neovim reads. zt.cmd and zacess-theme.cmd run this from Command Prompt.

$ErrorActionPreference = 'Stop'

$Themes = @(
    @{ Id = 'deep-contrast-dark'; Short = 'deep-dark'; Name = 'Zacess Deep Contrast Dark'; Dark = $true }
    @{ Id = 'deep-contrast-light'; Short = 'deep-light'; Name = 'Zacess Deep Contrast Light'; Dark = $false }
    @{ Id = 'high-contrast-dark'; Short = 'hc-dark'; Name = 'Zacess High Contrast Dark'; Dark = $true }
    @{ Id = 'high-contrast-light'; Short = 'hc-light'; Name = 'Zacess High Contrast Light'; Dark = $false }
    @{ Id = 'dark'; Short = 'dark'; Name = 'Zacess Dark'; Dark = $true }
    @{ Id = 'light'; Short = 'light'; Name = 'Zacess Light'; Dark = $false }
    @{ Id = 'cream'; Short = 'cream'; Name = 'Zacess Cream'; Dark = $false }
    @{ Id = 'yellow-on-black'; Short = 'yellow'; Name = 'Zacess Yellow on Black'; Dark = $true }
)

$StateFile = Join-Path $env:LOCALAPPDATA 'zacess\theme'
$EclipseWorkspace = if ($env:ZT_ECLIPSE_WORKSPACE) { $env:ZT_ECLIPSE_WORKSPACE } else { Join-Path $env:USERPROFILE 'eclipse-workspace' }
# editors\eclipse and editors\stm32cubeide sit beside shell\ in the same clone (shell\windows\scripts\zt.ps1)
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$EclipseThemes = if ($env:ZT_ECLIPSE_THEMES) { $env:ZT_ECLIPSE_THEMES } else { Join-Path $RepoRoot 'editors\eclipse\theme' }
$Stm32Themes = if ($env:ZT_STM32_THEMES) { $env:ZT_STM32_THEMES } else { Join-Path $RepoRoot 'editors\stm32cubeide\shared\theme' }

# STM32CubeIDE names its default workspace after its own version, so the newest one it has
# opened is the one in use
function Get-Stm32Workspace {
    if ($env:ZT_STM32_WORKSPACE) { return $env:ZT_STM32_WORKSPACE }
    $root = Join-Path $env:USERPROFILE 'STM32CubeIDE'
    if (-not (Test-Path $root)) { return $null }
    $found = Get-ChildItem -Path $root -Directory -Filter 'workspace_*' -ErrorAction SilentlyContinue |
        Where-Object { Test-Path (Join-Path $_.FullName '.metadata') } | Sort-Object LastWriteTime -Descending
    if ($found) { return $found[0].FullName }
    return $null
}

# terminal colour slots rather than fixed colours, so the output reads in every theme
$e = [char]27
$Ok = "$e[32m"; $Skip = "$e[33m"; $Bold = "$e[1m"; $Reset = "$e[0m"
if ($env:NO_COLOR) { $Ok = $Skip = $Bold = $Reset = '' }

function Find-Theme([string]$Word) {
    $key = ($Word.Trim().ToLowerInvariant() -replace ' ', '-') -replace '^zacess-', ''
    $Themes | Where-Object { $_.Id -eq $key -or $_.Short -eq $key } | Select-Object -First 1
}

function Write-Result([string]$Tool, [string]$Message, [bool]$Changed = $true) {
    $colour = if ($Changed) { $Ok } else { $Skip }
    Write-Host ("  {0}{1,-16}{2} {3}{4}{2}" -f $Bold, $Tool, $Reset, $colour, $Message)
}

function Test-SystemDark {
    $value = Get-ItemPropertyValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'AppsUseLightTheme' -ErrorAction SilentlyContinue
    return $value -eq 0
}

# JSON with comments: each value is swapped in the text itself, so comments, key order and spacing
# stay as they were. the result is parsed before it is saved
function Set-JsonKey([string]$Text, [string]$Key, [string]$Rendered) {
    $value = '(?:"(?:[^"\\]|\\.)*"|true|false|null|-?\d+(?:\.\d+)?|\{[^{}]*\})'
    $pattern = '("' + [regex]::Escape($Key) + '"\s*:\s*)' + $value
    if ([regex]::IsMatch($Text, $pattern)) {
        return ([regex]$pattern).Replace($Text, { param($m) $m.Groups[1].Value + $Rendered }, 1)
    }
    $indent = [regex]::Match($Text, '\n([ \t]+)"')
    $pad = if ($indent.Success) { $indent.Groups[1].Value } else { '    ' }
    $brace = $Text.IndexOf('{')
    return $Text.Substring(0, $brace + 1) + "`n$pad`"$Key`": $Rendered," + $Text.Substring($brace + 1)
}

function Edit-Json([string]$Path, [hashtable]$Changes) {
    $text = [IO.File]::ReadAllText($Path)
    $new = $text
    foreach ($key in $Changes.Keys) { $new = Set-JsonKey $new $key $Changes[$key] }
    $null = $new | ConvertFrom-Json
    if ($new -cne $text) { [IO.File]::WriteAllText($Path, $new) }
}

function ConvertTo-JsonValue($Value) {
    if ($Value -is [bool]) { return $Value.ToString().ToLowerInvariant() }
    return ($Value | ConvertTo-Json -Compress)
}

function Set-VSCode($Fixed, $Dark, $Light, $Now) {
    $path = Join-Path $env:APPDATA 'Code\User\settings.json'
    if (-not (Test-Path $path)) { return Write-Result 'VS Code' 'not installed, skipped' $false }
    if ($Fixed) {
        Edit-Json $path @{ 'workbench.colorTheme' = (ConvertTo-JsonValue $Fixed.Name); 'window.autoDetectColorScheme' = 'false' }
        return Write-Result 'VS Code' $Fixed.Name
    }
    Edit-Json $path @{
        'workbench.colorTheme' = (ConvertTo-JsonValue $Now.Name); 'window.autoDetectColorScheme' = 'true'
        'workbench.preferredDarkColorTheme' = (ConvertTo-JsonValue $Dark.Name)
        'workbench.preferredLightColorTheme' = (ConvertTo-JsonValue $Light.Name)
    }
    Write-Result 'VS Code' "following the system: $($Dark.Name) or $($Light.Name)"
}

function Set-Zed($Fixed, $Dark, $Light, $Now) {
    $path = Join-Path $env:APPDATA 'Zed\settings.json'
    if (-not (Test-Path $path)) { return Write-Result 'Zed' 'not installed, skipped' $false }
    if ($Fixed) {
        $mode = if ($Fixed.Dark) { 'dark' } else { 'light' }
        $value = "{ `"mode`": `"$mode`", `"light`": `"$($Light.Name)`", `"dark`": `"$($Dark.Name)`" }"
        Edit-Json $path @{ 'theme' = $value }
        return Write-Result 'Zed' $Fixed.Name
    }
    Edit-Json $path @{ 'theme' = "{ `"mode`": `"system`", `"light`": `"$($Light.Name)`", `"dark`": `"$($Dark.Name)`" }" }
    Write-Result 'Zed' "following the system: $($Dark.Name) or $($Light.Name)"
}

function Set-JetBrains($Fixed, $Dark, $Light, $Now) {
    $base = Join-Path $env:APPDATA 'JetBrains'
    $dirs = @(if (Test-Path $base) { Get-ChildItem $base -Directory | Where-Object { Test-Path (Join-Path $_.FullName 'options') } })
    if (-not $dirs) { return Write-Result 'JetBrains' 'not installed, skipped' $false }
    $ides = 'idea64', 'pycharm64', 'webstorm64', 'clion64', 'dataspell64', 'goland64', 'phpstorm64', 'rubymine64', 'rustrover64', 'rider64', 'studio64'
    if (Get-Process -Name $ides -ErrorAction SilentlyContinue) {
        return Write-Result 'JetBrains' 'an IDE is open, skipped: close it and run zt again' $false
    }
    $shown = if ($Fixed) { $Fixed } else { $Now }
    foreach ($dir in $dirs) {
        if (-not (Test-Path (Join-Path $dir.FullName 'plugins\zacess-themes'))) {
            Write-Result "  $($dir.Name)" 'Zacess Themes plugin not installed, skipped' $false
            continue
        }
        $laf = Join-Path $dir.FullName 'options\laf.xml'
        [xml]$doc = if (Test-Path $laf) { Get-Content -Raw $laf } else { '<application />' }
        $comp = $doc.DocumentElement.SelectSingleNode("component[@name='LafManager']")
        if (-not $comp) {
            $comp = $doc.CreateElement('component'); $comp.SetAttribute('name', 'LafManager')
            $null = $doc.DocumentElement.AppendChild($comp)
        }
        foreach ($child in @($comp.ChildNodes)) {
            # a remembered scheme per theme would win over the theme's own scheme
            if ($child.Name -in 'laf', 'lafs-to-previous-schemes' -or (-not $Fixed -and $child.Name -like 'preferred-*')) {
                $null = $comp.RemoveChild($child)
            }
        }
        $comp.SetAttribute('autodetect', $(if ($Fixed) { 'false' } else { 'true' }))
        $node = $doc.CreateElement('laf'); $node.SetAttribute('themeId', "zacess-$($shown.Id)"); $null = $comp.AppendChild($node)
        if (-not $Fixed) {
            $node = $doc.CreateElement('preferred-light-laf'); $node.SetAttribute('themeId', "zacess-$($Light.Id)"); $null = $comp.AppendChild($node)
            $node = $doc.CreateElement('preferred-dark-laf'); $node.SetAttribute('themeId', "zacess-$($Dark.Id)"); $null = $comp.AppendChild($node)
        }
        $doc.Save($laf)
        $schemeFile = Join-Path $dir.FullName 'options\colors.scheme.xml'
        [xml]$doc = if (Test-Path $schemeFile) { Get-Content -Raw $schemeFile } else { '<application />' }
        $comp = $doc.DocumentElement.SelectSingleNode("component[@name='EditorColorsManagerImpl']")
        if (-not $comp) {
            $comp = $doc.CreateElement('component'); $comp.SetAttribute('name', 'EditorColorsManagerImpl')
            $null = $doc.DocumentElement.AppendChild($comp)
        }
        $node = $comp.SelectSingleNode('global_color_scheme')
        if (-not $node) { $node = $doc.CreateElement('global_color_scheme'); $null = $comp.AppendChild($node) }
        $node.SetAttribute('name', $shown.Name)
        $doc.Save($schemeFile)
        $message = if ($Fixed) { $Fixed.Name } else { "Sync with OS: $($Dark.Name) or $($Light.Name)" }
        Write-Result "  $($dir.Name)" $message
    }
}

function Set-Neovim($Fixed, $Dark, $Light, $Now) {
    New-Item -ItemType Directory -Force (Split-Path $StateFile) | Out-Null
    $line = if ($Fixed) { $Fixed.Id } else { "auto $($Dark.Id) $($Light.Id)" }
    [IO.File]::WriteAllText($StateFile, "$line`n")
    if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) { return Write-Result 'Neovim' 'not installed, theme saved for later' $false }
    $message = if ($Fixed) { $Fixed.Name } else { 'following the system' }
    Write-Result 'Neovim' "$message, on next focus or start"
}

function Set-Eclipse($Fixed, $Dark, $Light, $Now) {
    Set-EclipseLike 'Eclipse' $EclipseWorkspace $EclipseThemes 'eclipse' $Fixed $Now
}

function Set-STM32CubeIDE($Fixed, $Dark, $Light, $Now) {
    $workspace = Get-Stm32Workspace
    if (-not $workspace) { return Write-Result 'STM32CubeIDE' 'no workspace, skipped' $false }
    Set-EclipseLike 'STM32CubeIDE' $workspace $Stm32Themes 'stm32cubeide' $Fixed $Now
}

# Eclipse and STM32CubeIDE (built on Eclipse) keep the theme as plain preference files in a
# workspace, written back from memory on exit, so both are changed only while closed
function Set-EclipseLike($Label, $Workspace, $ThemeDir, $ProcessName, $Fixed, $Now) {
    $settings = Join-Path $Workspace '.metadata\.plugins\org.eclipse.core.runtime\.settings'
    if (-not (Test-Path $settings)) { return Write-Result $Label 'no workspace, skipped' $false }
    if (Get-Process -Name $ProcessName -ErrorAction SilentlyContinue) { return Write-Result $Label 'open, skipped: quit it and run zt again' $false }
    $theme = if ($Fixed) { $Fixed } else { $Now }
    $epf = Join-Path $ThemeDir "$($theme.Name).epf"
    if (-not (Test-Path $epf)) { return Write-Result $Label "no theme files in $ThemeDir, skipped" $false }
    $themeId = if ($theme.Dark) { 'org.eclipse.e4.ui.css.theme.e4_dark' } else { 'org.eclipse.e4.ui.css.theme.e4_default' }
    $fragments = @{ 'org.eclipse.e4.ui.css.swt.theme' = [ordered]@{ themeid = $themeId } }
    foreach ($file in $epf, (Join-Path $ThemeDir "$($theme.Name) borders.epf")) {
        if (-not (Test-Path $file)) { continue }
        foreach ($line in [IO.File]::ReadAllLines($file)) {
            if (-not $line.StartsWith('/instance/') -or -not $line.Contains('=')) { continue }
            $rest = $line.Substring(10)
            $slash = $rest.IndexOf('/')
            $plugin = $rest.Substring(0, $slash)
            $pair = $rest.Substring($slash + 1)
            $eq = $pair.IndexOf('=')
            if (-not $fragments.ContainsKey($plugin)) { $fragments[$plugin] = [ordered]@{} }
            $fragments[$plugin][$pair.Substring(0, $eq)] = $pair.Substring($eq + 1)
        }
    }
    foreach ($plugin in $fragments.Keys) {
        $target = Join-Path $settings "$plugin.prefs"
        $lines = if (Test-Path $target) { [IO.File]::ReadAllLines($target) } else { @('eclipse.preferences.version=1') }
        $keys = $fragments[$plugin]
        $done = @{}
        $out = [Collections.Generic.List[string]]::new()
        foreach ($line in $lines) {
            $i = $line.IndexOf('=')
            $key = if ($i -gt 0) { $line.Substring(0, $i) } else { $null }
            if ($key -and $keys.Contains($key)) {
                if (-not $done.ContainsKey($key)) { $out.Add("$key=$($keys[$key])"); $done[$key] = $true }
                continue
            }
            $out.Add($line)
        }
        foreach ($key in $keys.Keys) { if (-not $done.ContainsKey($key)) { $out.Add("$key=$($keys[$key])") } }
        [IO.File]::WriteAllLines($target, $out.ToArray())
    }
    $note = if ($Fixed) { '' } else { " ($Label cannot follow the system, so this matches it now)" }
    Write-Result $Label "$($theme.Name)$note"
}

function Set-WindowsTerminal($Fixed, $Dark, $Light, $Now) {
    $paths = @(
        (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'),
        (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json'),
        (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\settings.json')
    ) | Where-Object { Test-Path $_ }
    if (-not $paths) { return Write-Result 'Windows Terminal' 'not installed, skipped' $false }
    foreach ($path in $paths) {
        # the file allows comments, which are dropped here; Windows Terminal writes it the same way itself
        $settings = Get-Content -Raw $path | ConvertFrom-Json
        if (-not $settings.profiles.PSObject.Properties['defaults']) {
            $settings.profiles | Add-Member -NotePropertyName defaults -NotePropertyValue ([pscustomobject]@{})
        }
        $value = if ($Fixed) { $Fixed.Name } else { [pscustomobject]@{ dark = $Dark.Name; light = $Light.Name } }
        $settings.profiles.defaults | Add-Member -Force -NotePropertyName colorScheme -NotePropertyValue $value
        $settings | ConvertTo-Json -Depth 32 | Set-Content -Path $path -Encoding utf8
    }
    $message = if ($Fixed) { $Fixed.Name } else { "following the system: $($Dark.Name) or $($Light.Name)" }
    Write-Result 'Windows Terminal' $message
}

function Set-Alacritty($Fixed, $Dark, $Light, $Now) {
    $conf = Join-Path $env:APPDATA 'alacritty\alacritty.toml'
    if (-not (Test-Path $conf)) { return Write-Result 'Alacritty' 'not installed, skipped' $false }
    $theme = if ($Fixed) { $Fixed } else { $Now }
    $text = [IO.File]::ReadAllText($conf)
    if ($text -notmatch 'zacess-[\w-]+\.toml') { return Write-Result 'Alacritty' 'no Zacess import in alacritty.toml, skipped' $false }
    [IO.File]::WriteAllText($conf, ([regex]'zacess-[\w-]+\.toml').Replace($text, "zacess-$($theme.Id).toml", 1))
    $note = if ($Fixed) { '' } else { ' (Alacritty cannot follow the system, so this matches it now)' }
    Write-Result 'Alacritty' "$($theme.Name)$note"
}

# the apps below have an apply script of their own beside their settings, which finds the app,
# refuses while it is open and changes only its own keys, so zt runs that script. none of them can
# follow the system, so following it sets the theme for the current mode
function Invoke-AppScript($Label, $Script, $Fixed, $Now, [string]$Process, [string[]]$Extra = @()) {
    $theme = if ($Fixed) { $Fixed } else { $Now }
    $path = Join-Path $RepoRoot $Script
    if (-not (Test-Path $path)) { return Write-Result $Label "no apply script at $Script, skipped" $false }
    if ($Process -and (Get-Process -Name $Process -ErrorAction SilentlyContinue)) {
        return Write-Result $Label 'open, skipped: quit it and run zt again' $false
    }
    $output = @(& pwsh -NoProfile -File $path -Theme $theme.Id @Extra 2>&1 | ForEach-Object { "$_" })
    if ($LASTEXITCODE -ne 0) {
        $reason = ($output | Where-Object { $_.Trim() } | Select-Object -First 1)
        return Write-Result $Label "skipped: $reason" $false
    }
    # a script whose app is not set up here says so on its first line and exits cleanly
    if ($output.Count -and $output[0] -match 'skipped') { return Write-Result $Label 'not installed, skipped' $false }
    $note = if ($Fixed) { '' } else { " ($Label cannot follow the system, so this matches it now)" }
    Write-Result $Label "$($theme.Name)$note"
}

function Set-ArduinoIDE($Fixed, $Dark, $Light, $Now) {
    if (-not (Test-Path (Join-Path $env:USERPROFILE '.arduinoIDE\settings.json'))) { return Write-Result 'Arduino IDE' 'not installed, skipped' $false }
    Invoke-AppScript 'Arduino IDE' 'editors\arduino\windows\apply.ps1' $Fixed $Now 'Arduino IDE'
}

function Set-NotepadPlusPlus($Fixed, $Dark, $Light, $Now) {
    if (-not (Test-Path (Join-Path $env:APPDATA 'Notepad++\config.xml'))) { return Write-Result 'Notepad++' 'not installed, skipped' $false }
    Invoke-AppScript 'Notepad++' 'editors\notepad-plus-plus\windows\apply.ps1' $Fixed $Now 'notepad++'
}

function Set-Thonny($Fixed, $Dark, $Light, $Now) {
    if (-not (Test-Path (Join-Path $env:APPDATA 'Thonny\configuration.ini'))) { return Write-Result 'Thonny' 'not installed, skipped' $false }
    Invoke-AppScript 'Thonny' 'editors\thonny\windows\apply.ps1' $Fixed $Now 'thonny'
}

function Set-LTspice($Fixed, $Dark, $Light, $Now) {
    if (-not (Test-Path (Join-Path $env:APPDATA 'LTspice.ini')) -and -not (Test-Path (Join-Path $env:APPDATA 'LTspiceXVII.ini'))) { return Write-Result 'LTspice' 'not installed, skipped' $false }
    Invoke-AppScript 'LTspice' 'editors\ltspice\windows\apply.ps1' $Fixed $Now 'LTspice'
}

function Set-Proteus($Fixed, $Dark, $Light, $Now) {
    if (-not (Test-Path 'HKCU:\Software\Labcenter Electronics\Proteus 8 Professional\ARES')) { return Write-Result 'Proteus' 'not installed, skipped' $false }
    Invoke-AppScript 'Proteus' 'editors\proteus\windows\apply.ps1' $Fixed $Now 'PDS'
}

function Set-Zotero($Fixed, $Dark, $Light, $Now) {
    if (-not (Test-Path (Join-Path $env:APPDATA 'Zotero\Zotero\Profiles'))) { return Write-Result 'Zotero' 'not installed, skipped' $false }
    Invoke-AppScript 'Zotero' 'apps\zotero\windows\apply.ps1' $Fixed $Now 'zotero'
}

# a vault can live anywhere, so it is named once in OBSIDIAN_VAULT, which the apply script reads too.
# a synced vault carries its theme settings to every machine, so each machine's zt changes the same files
function Set-Obsidian($Fixed, $Dark, $Light, $Now) {
    if (-not (Test-Path (Join-Path $env:LOCALAPPDATA 'Programs\Obsidian\Obsidian.exe'))) { return Write-Result 'Obsidian' 'not installed, skipped' $false }
    if (-not $env:OBSIDIAN_VAULT) { return Write-Result 'Obsidian' 'no vault named in OBSIDIAN_VAULT, skipped' $false }
    Invoke-AppScript 'Obsidian' 'apps\obsidian\windows\apply.ps1' $Fixed $Now 'Obsidian'
}

# MATLAB saves settings only from a session that exits normally, so this takes about a minute
function Set-MATLAB($Fixed, $Dark, $Light, $Now) {
    if (-not (Get-ChildItem 'C:\Program Files\MATLAB' -Filter 'R20*' -Directory -ErrorAction SilentlyContinue)) { return Write-Result 'MATLAB' 'not installed, skipped' $false }
    Invoke-AppScript 'MATLAB' 'editors\matlab\windows\apply.ps1' $Fixed $Now 'MATLAB'
}

# Microchip Studio only imports colours through a running Studio, so its script starts Studio,
# imports the theme and, with -Close, quits it so the colours are saved (about a minute)
function Set-MicrochipStudio($Fixed, $Dark, $Light, $Now) {
    if (-not (Test-Path 'C:\Program Files (x86)\Atmel\Studio\7.0\AtmelStudio.exe')) { return Write-Result 'Microchip Studio' 'not installed, skipped' $false }
    Invoke-AppScript 'Microchip Studio' 'editors\microchip-studio\windows\apply.ps1' $Fixed $Now 'AtmelStudio' @('-Close')
}

function Set-KiCad($Fixed, $Dark, $Light, $Now) { Invoke-AppScript 'KiCad' 'editors\kicad\windows\apply.ps1' $Fixed $Now 'kicad' }
function Set-Vivado($Fixed, $Dark, $Light, $Now) { Invoke-AppScript 'Vivado' 'editors\vivado\windows\apply.ps1' $Fixed $Now 'vivado' }
function Set-Processing($Fixed, $Dark, $Light, $Now) { Invoke-AppScript 'Processing' 'editors\processing\windows\apply.ps1' $Fixed $Now 'Processing' }

function Get-ThemeName([string]$Id) {
    if (-not $Id) { return 'not set' }
    $theme = Find-Theme ($Id -replace '^zacess-', '')
    if ($theme) { return $theme.Name }
    return $Id
}

function Read-Prefs([string]$Path) {
    $map = @{}
    if (Test-Path $Path) {
        foreach ($line in [IO.File]::ReadAllLines($Path)) {
            $i = $line.IndexOf('=')
            if ($i -gt 0) { $map[$line.Substring(0, $i)] = $line.Substring($i + 1) }
        }
    }
    return $map
}

# each reader returns what the tool is on now, in the same words zt prints when it sets it
function Get-CurrentEclipse {
    return Get-CurrentEclipseLike $EclipseWorkspace $EclipseThemes
}

function Get-CurrentSTM32CubeIDE {
    $workspace = Get-Stm32Workspace
    if (-not $workspace) { return $null }
    return Get-CurrentEclipseLike $workspace $Stm32Themes
}

function Get-CurrentEclipseLike($Workspace, $ThemeDir) {
    $settings = Join-Path $Workspace '.metadata\.plugins\org.eclipse.core.runtime\.settings'
    if (-not (Test-Path $settings)) { return $null }
    # Eclipse keeps no theme name, so the editor colours are compared with each theme's file
    $best = $null; $bestScore = 0.0; $cache = @{}; $found = $false
    foreach ($theme in $Themes) {
        $epf = Join-Path $ThemeDir "$($theme.Name).epf"
        if (-not (Test-Path $epf)) { continue }
        $found = $true
        $total = 0; $hits = 0
        foreach ($line in [IO.File]::ReadAllLines($epf)) {
            if (-not $line.StartsWith('/instance/') -or -not $line.Contains('=')) { continue }
            $rest = $line.Substring(10)
            $slash = $rest.IndexOf('/')
            $plugin = $rest.Substring(0, $slash)
            $pair = $rest.Substring($slash + 1)
            $eq = $pair.IndexOf('=')
            if (-not $cache.ContainsKey($plugin)) { $cache[$plugin] = Read-Prefs (Join-Path $settings "$plugin.prefs") }
            $total++
            if ($cache[$plugin][$pair.Substring(0, $eq)] -ceq $pair.Substring($eq + 1)) { $hits++ }
        }
        $score = if ($total) { $hits / $total } else { 0 }
        if ($score -gt $bestScore) { $best = $theme; $bestScore = $score }
    }
    if (-not $found) { return 'no Zacess theme files to compare with' }
    if (-not $best) { return 'not a Zacess theme' }
    $workbench = (Read-Prefs (Join-Path $settings 'org.eclipse.e4.ui.css.swt.theme.prefs'))['themeid']
    $look = if ("$workbench".EndsWith('e4_dark')) { 'Dark' } else { 'Light' }
    if ($bestScore -eq 1) { return "fixed: $($best.Name), $look workbench" }
    return "not a Zacess theme (closest $($best.Name), $([math]::Round($bestScore * 100))% of its colours), $look workbench"
}

function Get-NewestVersionFolder([string]$Base, [string]$Pattern) {
    if (-not (Test-Path $Base)) { return $null }
    $found = Get-ChildItem $Base -Directory | Where-Object { $_.Name -match $Pattern } | Sort-Object { [version]($_.Name -replace '[^\d.]', '') } | Select-Object -Last 1
    if ($found) { return $found.FullName }
    return $null
}

function Get-CurrentKiCad {
    $base = if ($env:KICAD_CONFIG_HOME) { $env:KICAD_CONFIG_HOME } else { Join-Path $env:APPDATA 'kicad' }
    $config = Get-NewestVersionFolder $base '^\d+\.\d+$'
    $file = if ($config) { Join-Path $config 'eeschema.json' }
    if (-not $file -or -not (Test-Path $file)) { return $null }
    $value = (Get-Content -Raw $file | ConvertFrom-Json).appearance.color_theme
    if (-not $value) { return 'fixed: KiCad default' }
    if ($value -like 'zacess-*') { return "fixed: $(Get-ThemeName $value)" }
    return "fixed: $value"
}

# Vivado keeps no theme name, so its colours are compared with each theme's file
function Get-CurrentVivado {
    $config = Get-NewestVersionFolder (Join-Path $env:APPDATA 'Xilinx\Vivado') '^20\d\d\.\d+'
    $file = if ($config) { Join-Path $config 'vivado.xml' }
    if (-not $file -or -not (Test-Path $file)) { return $null }
    $colours = ([xml](Get-Content -Raw $file)).DocumentElement.SelectSingleNode('general_color')
    foreach ($theme in $Themes) {
        $path = Join-Path $RepoRoot "editors\vivado\shared\themes\zacess-$($theme.Id).json"
        if (-not (Test-Path $path)) { continue }
        $wanted = (Get-Content -Raw $path | ConvertFrom-Json).general_color
        $match = $null -ne $colours
        foreach ($property in $wanted.PSObject.Properties) {
            $node = if ($colours) { $colours.SelectSingleNode($property.Name) }
            if ($null -eq $node -or $node.GetAttribute('color') -ne $property.Value) { $match = $false; break }
        }
        if ($match) { return "fixed: $($theme.Name)" }
    }
    return 'not a Zacess theme'
}

# Microchip Studio keeps imported colours in its own binary store, so only its dark or light
# environment theme can be read back, not which Zacess theme it came from
function Get-CurrentMicrochipStudio {
    $key = 'HKCU:\Software\Atmel\AtmelStudio\7.0\ApplicationPrivateSettings\Microsoft\VisualStudio'
    $value = "$((Get-ItemProperty -Path $key -Name ColorTheme -ErrorAction SilentlyContinue).ColorTheme)"
    if (-not $value) { return $null }
    if ($value -match '1ded0138-47ce-435e-84ef-9ec1f439b749') { return 'dark environment theme (the Zacess theme itself is not recorded)' }
    if ($value -match 'de3dbbcd-f642-433c-8353-8f1df4370aba') { return 'light environment theme (the Zacess theme itself is not recorded)' }
    return 'not a Zacess environment theme'
}

# the theme Processing uses is the theme.txt in its sketchbook, which names itself on its first line
function Get-CurrentProcessing {
    $prefs = Read-Prefs (Join-Path $env:APPDATA 'Processing\preferences.txt')
    $sketchbook = $prefs['sketchbook.path.four']
    if (-not $sketchbook) { return $null }
    $file = Join-Path $sketchbook 'theme.txt'
    if (-not (Test-Path $file)) { return "fixed: $(if ($prefs['theme']) { $prefs['theme'] } else { 'default' })" }
    $first = [IO.File]::ReadLines($file) | Select-Object -First 1
    if ($first -match '^# Zacess theme for Processing: (.+)$') { return "fixed: $($Matches[1])" }
    return 'fixed: a theme.txt that is not a Zacess theme'
}

function Show-Current {
    $state =@(if (Test-Path $StateFile) { ([IO.File]::ReadAllText($StateFile)).Trim() -split '\s+' } else { @('deep-contrast-dark') })
    $neovim = if ($state[0] -eq 'auto') {
        $dark = if ($state.Count -gt 1) { $state[1] } else { 'deep-contrast-dark' }
        $light = if ($state.Count -gt 2) { $state[2] } else { 'deep-contrast-light' }
        "following the system: $(Get-ThemeName $dark) or $(Get-ThemeName $light)"
    } else { "fixed: $(Get-ThemeName $state[0])" }
    Write-Host "zt state: $neovim"

    $vs = Join-Path $env:APPDATA 'Code\User\settings.json'
    if (Test-Path $vs) {
        $data = Get-Content -Raw $vs | ConvertFrom-Json
        $text = if ($data.'window.autoDetectColorScheme') {
            "following the system: $($data.'workbench.preferredDarkColorTheme') or $($data.'workbench.preferredLightColorTheme')"
        } else { "fixed: $($data.'workbench.colorTheme')" }
        Write-Result 'VS Code' $text $false
    }

    $zed =Join-Path $env:APPDATA 'Zed\settings.json'
    if (Test-Path $zed) {
        $theme = (Get-Content -Raw $zed | ConvertFrom-Json).theme
        $text = if ($theme -is [string]) { "fixed: $theme" }
                elseif (-not $theme) { 'fixed: default' }
                elseif ($theme.mode -eq 'system' -or -not $theme.mode) { "following the system: $($theme.dark) or $($theme.light)" }
                else { "fixed: $($theme.($theme.mode))" }
        Write-Result 'Zed' $text $false
    }

    $base = Join-Path $env:APPDATA 'JetBrains'
    if (Test-Path $base) {
        foreach ($dir in Get-ChildItem $base -Directory | Where-Object { Test-Path (Join-Path $_.FullName 'options') }) {
            $laf = Join-Path $dir.FullName 'options\laf.xml'
            $schemeFile = Join-Path $dir.FullName 'options\colors.scheme.xml'
            $comp = if (Test-Path $laf) { ([xml](Get-Content -Raw $laf)).DocumentElement.SelectSingleNode("component[@name='LafManager']") }
            $node = if (Test-Path $schemeFile) { ([xml](Get-Content -Raw $schemeFile)).DocumentElement.SelectSingleNode('//global_color_scheme') }
            $editor = if ($node) { $node.GetAttribute('name') } else { 'default' }
            $text = if ($comp -and $comp.GetAttribute('autodetect') -eq 'true') {
                $d = $comp.SelectSingleNode('preferred-dark-laf'); $l = $comp.SelectSingleNode('preferred-light-laf')
                "Sync with OS: $(Get-ThemeName $(if ($d) { $d.GetAttribute('themeId') })) or $(Get-ThemeName $(if ($l) { $l.GetAttribute('themeId') }))"
            } else {
                $n = if ($comp) { $comp.SelectSingleNode('laf') }
                "fixed: $(Get-ThemeName $(if ($n) { $n.GetAttribute('themeId') }))"
            }
            $plugin = if (Test-Path (Join-Path $dir.FullName 'plugins\zacess-themes')) { '' } else { ' (no Zacess plugin)' }
            Write-Result "  $($dir.Name)" "$text, editor $editor$plugin" $false
        }
    }

    Write-Result 'Neovim' $neovim $false

    $eclipse = Get-CurrentEclipse
    if ($eclipse) { Write-Result 'Eclipse' $eclipse $false }
    $stm32 = Get-CurrentSTM32CubeIDE
    if ($stm32) { Write-Result 'STM32CubeIDE' $stm32 $false }
    $kicad = Get-CurrentKiCad
    if ($kicad) { Write-Result 'KiCad' $kicad $false }
    $vivado = Get-CurrentVivado
    if ($vivado) { Write-Result 'Vivado' $vivado $false }
    $processing = Get-CurrentProcessing
    if ($processing) { Write-Result 'Processing' $processing $false }
    $microchip = Get-CurrentMicrochipStudio
    if ($microchip) { Write-Result 'Microchip Studio' $microchip $false }

    $terminals = @(
        (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'),
        (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json'),
        (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\settings.json')
    ) | Where-Object { Test-Path $_ }
    foreach ($path in $terminals) {
        $scheme = (Get-Content -Raw $path | ConvertFrom-Json).profiles.defaults.colorScheme
        $text = if ($scheme -is [string]) { "fixed: $scheme" }
                elseif ($scheme) { "following the system: $($scheme.dark) or $($scheme.light)" }
                else { 'fixed: default' }
        Write-Result 'Windows Terminal' $text $false
    }

    $alacritty = Join-Path $env:APPDATA 'alacritty\alacritty.toml'
    if (Test-Path $alacritty) {
        $m = [regex]::Match([IO.File]::ReadAllText($alacritty), 'zacess-([\w-]+)\.toml')
        Write-Result 'Alacritty' $(if ($m.Success) { "fixed: $(Get-ThemeName $m.Groups[1].Value)" } else { 'fixed: no Zacess import' }) $false
    }

    $arduino = Join-Path $env:USERPROFILE '.arduinoIDE\settings.json'
    if (Test-Path $arduino) { Write-Result 'Arduino IDE' "fixed: $((Get-Content -Raw $arduino | ConvertFrom-Json).'workbench.colorTheme')" $false }

    $npp = Join-Path $env:APPDATA 'Notepad++\config.xml'
    if (Test-Path $npp) {
        $mode = ([xml](Get-Content -Raw $npp)).NotepadPlus.GUIConfigs.GUIConfig | Where-Object { $_.name -eq 'DarkMode' }
        $file = if ($mode.enable -eq 'yes') { $mode.darkThemeName } else { $mode.lightThemeName }
        Write-Result 'Notepad++' "fixed: $(if ($file) { $file -replace '\.xml$', '' } else { 'default' })" $false
    }

    $thonny = Join-Path $env:APPDATA 'Thonny\configuration.ini'
    if (Test-Path $thonny) {
        $m = Select-String -Path $thonny -Pattern '^syntax_theme = (.+)$' | Select-Object -First 1
        Write-Result 'Thonny' "fixed: $(if ($m) { $m.Matches[0].Groups[1].Value } else { 'default' })" $false
    }

    $ltspice = @((Join-Path $env:APPDATA 'LTspice.ini'), (Join-Path $env:APPDATA 'LTspiceXVII.ini')) | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($ltspice) {
        $text = [Text.Encoding]::GetEncoding(28591).GetString([IO.File]::ReadAllBytes($ltspice))
        $match = $Themes | Where-Object {
            $file = Join-Path $RepoRoot "editors\ltspice\shared\themes\$($_.Name).ini"
            (Test-Path $file) -and -not (Get-Content $file | Where-Object { $_ -match '^\w+=\d+$' -and $text -notmatch "(?m)^$([regex]::Escape($_))\r?$" })
        } | Select-Object -First 1
        Write-Result 'LTspice' $(if ($match) { "fixed: $($match.Name)" } else { 'fixed: not a Zacess theme' }) $false
    }

    $proteus = 'HKCU:\Software\Labcenter Electronics\Proteus 8 Professional\ARES\Settings'
    if (Test-Path $proteus) {
        $set = (Get-ItemProperty $proteus).'Active Colour Set'
        $match = $Themes | Where-Object {
            $file = Join-Path $RepoRoot "editors\proteus\shared\themes\$($_.Name).json"
            (Test-Path $file) -and (Get-Content -Raw $file | ConvertFrom-Json).set -eq $set
        } | Select-Object -First 1
        Write-Result 'Proteus' "fixed: $(if ($match) { $match.Name } else { $set })" $false
    }

    $zotero = Get-ChildItem (Join-Path $env:APPDATA 'Zotero\Zotero\Profiles') -Directory -ErrorAction SilentlyContinue | ForEach-Object { Join-Path $_.FullName 'user.js' } | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($zotero) {
        $js = [IO.File]::ReadAllText($zotero)
        $mode = switch -regex ($js) { 'toolbar-theme", 0' { 'dark mode' } 'toolbar-theme", 1' { 'light mode' } default { 'following the system' } }
        $reader = [regex]::Match($js, 'reader\.(dark|light)Theme", "([^"]*)"')
        Write-Result 'Zotero' "fixed: $mode, reader $(if ($reader.Success -and $reader.Groups[2].Value) { $reader.Groups[2].Value } else { 'original' })" $false
    }

    $vault = if ($env:OBSIDIAN_VAULT) { Join-Path $env:OBSIDIAN_VAULT '.obsidian' }
    if ($vault -and (Test-Path (Join-Path $vault 'appearance.json'))) {
        $look = Get-Content -Raw (Join-Path $vault 'appearance.json') | ConvertFrom-Json
        $style = Join-Path $vault 'plugins\obsidian-style-settings\data.json'
        $contrast = if (Test-Path $style) { (Get-Content -Raw $style | ConvertFrom-Json).'zacess-theme@@zacess-contrast' }
        $text = if ($look.cssTheme -ne 'Zacess') { "fixed: $($look.cssTheme) theme" }
                elseif ($contrast -and $contrast -ne 'zacess-follow') { "fixed: $(Get-ThemeName ($contrast -replace '^zacess-', ''))" }
                elseif ($look.theme -eq 'obsidian') { 'fixed: Zacess Dark' } else { 'fixed: Zacess Light' }
        Write-Result 'Obsidian' $text $false
    }

    $mlsettings = Get-ChildItem (Join-Path $env:APPDATA 'MathWorks\MATLAB') -Directory -Filter 'R20*' -ErrorAction SilentlyContinue | Sort-Object Name -Descending | ForEach-Object { Join-Path $_.FullName 'matlab.mlsettings' } | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($mlsettings) {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $zip = [IO.Compression.ZipFile]::OpenRead($mlsettings)
        try {
            $read = { param($entry) $e = $zip.Entries | Where-Object FullName -eq $entry; if ($e) { $r = New-Object IO.StreamReader($e.Open()); try { $r.ReadToEnd() } finally { $r.Close() } } }
            # MATLAB writes a value as {"mwdata":[...]} and the Color Theme Extensions add-on as a plain
            # string or array, so both forms are read
            $mode = [regex]::Match("$(& $read 'fsroot/settingstree/matlab/appearance/settings.json')", 'MATLABTheme","value":"(?:\{\\"mwdata\\":\[)?\\"(Dark|Light)\\"').Groups[1].Value
            $keyword = [regex]::Match("$(& $read 'fsroot/settingstree/matlab/colors/settings.json')", 'KeywordColor","value":"(?:\{\\"mwdata\\":)?\[(\d+),(\d+),(\d+)')
        } finally { $zip.Dispose() }
        $match = if ($keyword.Success) {
            $Themes | Where-Object {
                $file = Join-Path $RepoRoot "editors\matlab\shared\themes\$($_.Name).json"
                (Test-Path $file) -and ((Get-Content -Raw $file | ConvertFrom-Json).settings.'matlab.colors.KeywordColor' -join ',') -eq "$($keyword.Groups[1].Value),$($keyword.Groups[2].Value),$($keyword.Groups[3].Value)"
            } | Select-Object -First 1
        }
        Write-Result 'MATLAB' "fixed: $(if ($match) { $match.Name } else { 'not a Zacess theme' }), $(if ($mode) { $mode } else { 'System' }) desktop" $false
    }
}

$command = if ($args.Count) { [string]$args[0] } else { 'help' }
switch ($command) {
    { $_ -in 'help', '-h', '--help' } {
        Get-Content $PSCommandPath | Select-Object -Skip 2 -First 5 | ForEach-Object { $_.TrimStart('#').TrimStart() }
        exit 0
    }
    'list' {
        $current = @(if (Test-Path $StateFile) { ([IO.File]::ReadAllText($StateFile)).Trim() -split '\s+' } else { @('deep-contrast-dark') })
        foreach ($theme in $Themes) {
            $mark = if ($current -contains $theme.Id) { ' *' } else { '' }
            Write-Host ("  {0,-11} {1}{2}" -f $theme.Short, $theme.Name, $mark)
        }
        exit 0
    }
    'current' {
        try { Show-Current } catch { [Console]::Error.WriteLine("could not read a setting: $($_.Exception.Message)") }
        exit 0
    }
}

if ($command -eq 'auto') {
    $dark = Find-Theme $(if ($args.Count -gt 1) { $args[1] } else { 'deep-contrast-dark' })
    $light = Find-Theme $(if ($args.Count -gt 2) { $args[2] } else { 'deep-contrast-light' })
    if (-not $dark -or -not $light) { [Console]::Error.WriteLine('Unknown theme. Run zt list for the names.'); exit 1 }
    $now = if (Test-SystemDark) { $dark } else { $light }
    $fixed = $null
    Write-Host "${Bold}Following the system${Reset}: $($dark.Name) in dark mode, $($light.Name) in light mode (now $(if ($now.Dark) { 'dark' } else { 'light' }))"
} else {
    $fixed = Find-Theme ($args -join ' ')
    if (-not $fixed) { [Console]::Error.WriteLine("Unknown theme: $($args -join ' '). Run zt list for the names."); exit 1 }
    $dark = if ($fixed.Dark) { $fixed } else { Find-Theme 'deep-contrast-dark' }
    $light = if (-not $fixed.Dark) { $fixed } else { Find-Theme 'deep-contrast-light' }
    $now = $fixed
    Write-Host "${Bold}$($fixed.Name)${Reset} everywhere, not following the system"
}

foreach ($tool in 'Set-VSCode', 'Set-Zed', 'Set-JetBrains', 'Set-Neovim', 'Set-Eclipse', 'Set-STM32CubeIDE', 'Set-KiCad', 'Set-Vivado',
    'Set-WindowsTerminal', 'Set-Alacritty', 'Set-ArduinoIDE', 'Set-NotepadPlusPlus', 'Set-Thonny', 'Set-LTspice', 'Set-Proteus', 'Set-Zotero',
    'Set-Obsidian', 'Set-MATLAB', 'Set-Processing', 'Set-MicrochipStudio') {
    try {
        & $tool $fixed $dark $light $now
    } catch {
        # one broken config never stops the other tools
        Write-Result ($tool -replace '^Set-', '') "failed: $($_.Exception.Message)" $false
    }
}
