# installs the Zacess Themes plugin into every JetBrains IDE, applies the tracked settings and sets
# the theme.
# usage: .\apply.ps1 [-Theme <theme>] [-ConfigDir <JetBrains config root>] [-Programs <folder>]
#   (the root defaults to %APPDATA%\JetBrains; the IDEs themselves are looked for under
#   %LOCALAPPDATA%\Programs, where Toolbox and the standalone installers put them)
#
# -Theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark.
#
# for every IDE that has been started once: a theme plugin older than the pin is replaced by the
# pinned release. one that is missing is installed through
# the IDE's own installPlugins command (its launcher comes from product-info.json) or, with no
# launcher found, from the pinned release in ..\shared\theme-package.json checked against its
# digest; the colour schemes, file template and keymap in this folder are copied in with the
# Windows font files from ..\options\windows; the custom keymap is made active once the VSCode keymap
# plugin is there; laf.xml and colors.scheme.xml are written the way zt.ps1 writes them; and new
# projects default to ~\dev\projects, as JetBrains' own $USER_HOME$ macro. only those files
# change; nothing is backed up: the repo holds every value this writes.
#
# the IDEs write their settings back on exit, so the script refuses to run while one is open.
param(
    [string]$Theme = 'deep-dark',
    [string]$ConfigDir = (Join-Path $env:APPDATA 'JetBrains'),
    [string]$Programs = (Join-Path $env:LOCALAPPDATA 'Programs')
)

$ErrorActionPreference = 'Stop'
$shared = Join-Path $PSScriptRoot '..\shared'
# the tracked settings sit in the folder above: colors, file-templates, keymaps and options
$folder = Join-Path $PSScriptRoot '..'
$keymap = 'JetBrains Custom (VSCode-based) windows-linux'
$keymapPlugin = 'com.intellij.plugins.vscodekeymap'
$projects = Join-Path $HOME 'dev\projects'
$projectsValue = '$USER_HOME$/dev/projects'
$package = Get-Content (Join-Path $shared 'theme-package.json') -Raw | ConvertFrom-Json

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

$dirs = @(Get-ChildItem $ConfigDir -Directory -ErrorAction SilentlyContinue | Where-Object { Test-Path (Join-Path $_.FullName 'options') })
if (-not $dirs) {
    Write-Output "JetBrains: no IDE has been started yet (no config folder with options\ under $ConfigDir), skipped."
    Write-Output 'Install an IDE, start it once, quit it, then run this again or pass -ConfigDir.'
    exit 0
}
$ides = 'idea64', 'pycharm64', 'webstorm64', 'clion64', 'dataspell64', 'goland64', 'phpstorm64', 'rubymine64', 'rustrover64', 'rider64', 'studio64'
if (Get-Process -Name $ides -ErrorAction SilentlyContinue) {
    [Console]::Error.WriteLine('A JetBrains IDE is running. Quit it first, then run this again.')
    exit 1
}
Write-Output "Settings: $ConfigDir"

# each installed IDE by its config folder name: product-info.json names the launcher, the config
# folder and the bundled plugins
$infos = @{}
foreach ($infoFile in Get-ChildItem -Path $Programs -Filter 'product-info.json' -Depth 1 -File -ErrorAction SilentlyContinue) {
    $info = Get-Content -Raw -LiteralPath $infoFile.FullName | ConvertFrom-Json
    $launch = @($info.launch) | Select-Object -First 1
    if ($info.dataDirectoryName -and $launch.launcherPath -and -not $infos.ContainsKey($info.dataDirectoryName)) {
        $infos[$info.dataDirectoryName] = @{ Info = $info; Launcher = (Join-Path $infoFile.DirectoryName ($launch.launcherPath -replace '/', '\')) }
    }
}

# the ids of the plugins in a config folder's plugins\: each a jar or a folder of jars under lib\.
# a plugin with no <id> is known by its <name>, as the IDE itself does
function Get-PluginIds([string]$PluginsDir) {
    if (-not (Test-Path -LiteralPath $PluginsDir)) { return @() }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    foreach ($item in Get-ChildItem -LiteralPath $PluginsDir) {
        $jars = if ($item.PSIsContainer) { Get-ChildItem -LiteralPath (Join-Path $item.FullName 'lib') -Filter '*.jar' -ErrorAction SilentlyContinue } elseif ($item.Extension -eq '.jar') { $item } else { @() }
        foreach ($jar in $jars) {
            $zip = try { [IO.Compression.ZipFile]::OpenRead($jar.FullName) } catch { $null }
            if (-not $zip) { continue }
            try {
                $entry = $zip.GetEntry('META-INF/plugin.xml')
                if (-not $entry) { continue }
                $reader = [IO.StreamReader]::new($entry.Open())
                $manifest = $reader.ReadToEnd()
                $reader.Dispose()
                $match = [regex]::Match($manifest, '<id>\s*([^<]+?)\s*</id>')
                if (-not $match.Success) { $match = [regex]::Match($manifest, '<name>\s*([^<]+?)\s*</name>') }
                if ($match.Success) { $match.Groups[1].Value }
                break
            } finally {
                $zip.Dispose()
            }
        }
    }
}

function Test-ThemePlugin($Dir) {
    (Test-Path (Join-Path $Dir.FullName "plugins\$($package.folder)")) -or ((Get-PluginIds (Join-Path $Dir.FullName 'plugins')) -contains $package.id)
}

# the version of the Zacess Themes plugin in a config folder's plugins\ ($null when it is not there),
# as editors\jetbrains\shared\apply.py reads it on the Mac and Linux
function Get-ThemePluginVersion($Dir) {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    foreach ($jar in Get-ChildItem -LiteralPath (Join-Path $Dir.FullName "plugins\$($package.folder)\lib") -Filter '*.jar' -ErrorAction SilentlyContinue | Sort-Object Name) {
        $zip = try { [IO.Compression.ZipFile]::OpenRead($jar.FullName) } catch { $null }
        if (-not $zip) { continue }
        try {
            $entry = $zip.GetEntry('META-INF/plugin.xml')
            if (-not $entry) { continue }
            $reader = [IO.StreamReader]::new($entry.Open())
            $manifest = $reader.ReadToEnd()
            $reader.Dispose()
            $match = [regex]::Match($manifest, '<version>\s*([^<]+?)\s*</version>')
            if ($match.Success) { return $match.Groups[1].Value }
        } finally {
            $zip.Dispose()
        }
    }
    return $null
}

$release = $null
# the pinned release, downloaded once per run and checked against its digest
function Get-PinnedRelease {
    if (-not $script:release) {
        $download = Join-Path ([IO.Path]::GetTempPath()) "zacess-themes-$PID.zip"
        Invoke-WebRequest -Uri $package.url -OutFile $download -UseBasicParsing
        if ((Get-FileHash $download -Algorithm SHA256).Hash -ne $package.sha256) {
            Remove-Item $download -Force -ErrorAction SilentlyContinue
            [Console]::Error.WriteLine('The Zacess Themes download does not match its pinned checksum, so it was not installed')
            exit 1
        }
        $script:release = $download
    }
    return $script:release
}

# a copy older than the pin is never brought up to it by a check on the plugin being there, so it
# is replaced by the pinned release. the IDE loads it on its next start
function Update-ThemePlugin($Dir, [string]$Installed) {
    $folder = Join-Path $Dir.FullName "plugins\$($package.folder)"
    $archive = Get-PinnedRelease
    Remove-Item -LiteralPath $folder -Recurse -Force
    Expand-Archive -LiteralPath $archive -DestinationPath (Join-Path $Dir.FullName 'plugins') -Force
    Write-Output "  changed    $($Dir.Name)  plugins\$($package.folder) $Installed to $($package.version) (restart the IDE to load it)"
}

function Install-ThemePlugin($Dir) {
    $launcher = if ($infos.ContainsKey($Dir.Name)) { $infos[$Dir.Name].Launcher }
    if ($launcher -and (Test-Path -LiteralPath $launcher)) {
        # the IDE starts without a window, installs from the Marketplace and exits; the pipe makes
        # PowerShell wait for it
        & $launcher installPlugins $package.id | Out-Null
        if (Test-ThemePlugin $Dir) {
            Write-Output "  added      $($Dir.Name)  plugins\$($package.folder) (from the Marketplace, by $(Split-Path $launcher -Leaf) installPlugins)"
            return
        }
        $reason = "$(Split-Path $launcher -Leaf) installPlugins left nothing behind, exit $LASTEXITCODE"
    } else {
        $reason = 'no launcher found for it'
    }
    $archive = Get-PinnedRelease
    $plugins = Join-Path $Dir.FullName 'plugins'
    New-Item -ItemType Directory -Force $plugins | Out-Null
    # the zip unpacks into its own folder (zacess-themes\lib\*.jar), the layout the IDE reads
    Expand-Archive -LiteralPath $archive -DestinationPath $plugins -Force
    Write-Output "  added      $($Dir.Name)  plugins\$($package.folder) (from the pinned release $($package.version), $reason)"
}

function Copy-Tracked($Dir, [string]$Source, [string]$Relative) {
    $target = Join-Path $Dir.FullName $Relative
    $want = [IO.File]::ReadAllBytes($Source)
    $status = if (-not (Test-Path -LiteralPath $target)) { 'added    ' }
              elseif (-not [Linq.Enumerable]::SequenceEqual([IO.File]::ReadAllBytes($target), $want)) { 'changed  ' }
              else { 'unchanged' }
    if ($status -ne 'unchanged') {
        New-Item -ItemType Directory -Force (Split-Path -Parent $target) | Out-Null
        [IO.File]::WriteAllBytes($target, $want)
    }
    Write-Output "  $status  $($Dir.Name)  $Relative"
}

function Set-ActiveKeymap($Dir) {
    $bundled = if ($infos.ContainsKey($Dir.Name)) { @($infos[$Dir.Name].Info.bundledPlugins) } else { @() }
    $installed = (Get-PluginIds (Join-Path $Dir.FullName 'plugins')) -contains $keymapPlugin -or (Test-Path (Join-Path $Dir.FullName 'plugins\keymap-vscode'))
    if (-not ($bundled -contains $keymapPlugin) -and -not $installed) {
        # the custom keymap's parent comes from that plugin, so without it the keymap would not load
        Write-Output "  skipped    $($Dir.Name)  options\windows\keymap.xml (install $keymapPlugin first)"
        return
    }
    $file = Join-Path $Dir.FullName 'options\windows\keymap.xml'
    $current = if (Test-Path -LiteralPath $file) { ([xml](Get-Content -Raw -LiteralPath $file)).SelectSingleNode('//active_keymap') }
    if ($current -and $current.GetAttribute('name') -eq $keymap) {
        Write-Output "  unchanged  $($Dir.Name)  options\windows\keymap.xml"
        return
    }
    New-Item -ItemType Directory -Force (Split-Path -Parent $file) | Out-Null
    $text = "<application>`n  <component name=`"KeymapManager`">`n    <active_keymap name=`"$keymap`" />`n  </component>`n</application>"
    [IO.File]::WriteAllText($file, $text, (New-Object Text.UTF8Encoding $false))
    Write-Output "  $(if ($current) { 'changed  ' } else { 'added    ' })  $($Dir.Name)  options\windows\keymap.xml"
}

# laf.xml and colors.scheme.xml the way zt.ps1 writes them for a fixed theme
function Set-ThemeFiles($Dir) {
    $laf = Join-Path $Dir.FullName 'options\laf.xml'
    $before = if (Test-Path -LiteralPath $laf) { [IO.File]::ReadAllText($laf) }
    [xml]$doc = if ($before) { $before } else { '<application />' }
    $comp = $doc.DocumentElement.SelectSingleNode("component[@name='LafManager']")
    if (-not $comp) {
        $comp = $doc.CreateElement('component'); $comp.SetAttribute('name', 'LafManager')
        $null = $doc.DocumentElement.AppendChild($comp)
    }
    foreach ($child in @($comp.ChildNodes)) {
        # a remembered scheme per theme would win over the theme's own scheme
        if ($child.Name -in 'laf', 'lafs-to-previous-schemes') { $null = $comp.RemoveChild($child) }
    }
    $comp.SetAttribute('autodetect', 'false')
    $node = $doc.CreateElement('laf'); $node.SetAttribute('themeId', "zacess-$($wanted.Id)"); $null = $comp.AppendChild($node)
    $doc.Save($laf)
    $status = if ($null -eq $before) { 'added    ' } elseif ([IO.File]::ReadAllText($laf) -ceq $before) { 'unchanged' } else { 'changed  ' }
    Write-Output "  $status  $($Dir.Name)  options\laf.xml"

    $schemeFile = Join-Path $Dir.FullName 'options\colors.scheme.xml'
    $before = if (Test-Path -LiteralPath $schemeFile) { [IO.File]::ReadAllText($schemeFile) }
    [xml]$doc = if ($before) { $before } else { '<application />' }
    $comp = $doc.DocumentElement.SelectSingleNode("component[@name='EditorColorsManagerImpl']")
    if (-not $comp) {
        $comp = $doc.CreateElement('component'); $comp.SetAttribute('name', 'EditorColorsManagerImpl')
        $null = $doc.DocumentElement.AppendChild($comp)
    }
    $node = $comp.SelectSingleNode('global_color_scheme')
    if (-not $node) { $node = $doc.CreateElement('global_color_scheme'); $null = $comp.AppendChild($node) }
    $node.SetAttribute('name', $wanted.Name)
    $doc.Save($schemeFile)
    $status = if ($null -eq $before) { 'added    ' } elseif ([IO.File]::ReadAllText($schemeFile) -ceq $before) { 'unchanged' } else { 'changed  ' }
    Write-Output "  $status  $($Dir.Name)  options\colors.scheme.xml"
}

# every IDE offers ~\dev\projects for a new project, written only when the value differs and
# keeping the file's other options
function Set-ProjectDirectory($Dir) {
    $file = Join-Path $Dir.FullName 'options\ide.general.xml'
    [xml]$doc = if (Test-Path -LiteralPath $file) { Get-Content -Raw -LiteralPath $file } else { '<application />' }
    $component = $doc.DocumentElement.SelectSingleNode("component[@name='GeneralSettings']")
    if (-not $component) {
        $component = $doc.CreateElement('component'); $component.SetAttribute('name', 'GeneralSettings')
        $null = $doc.DocumentElement.AppendChild($component)
    }
    $option = $component.SelectSingleNode("option[@name='defaultProjectDirectory']")
    if ($option -and $option.GetAttribute('value') -eq $projectsValue) {
        Write-Output "  unchanged  $($Dir.Name)  options\ide.general.xml defaultProjectDirectory"
        return
    }
    $status = if ($option) { 'changed  ' } else { 'added    ' }
    if (-not $option) {
        $option = $doc.CreateElement('option'); $option.SetAttribute('name', 'defaultProjectDirectory')
        $null = $component.AppendChild($option)
    }
    $option.SetAttribute('value', $projectsValue)
    $doc.Save($file)
    Write-Output "  $status  $($Dir.Name)  options\ide.general.xml defaultProjectDirectory"
}

if (-not (Test-Path $projects)) {
    New-Item -ItemType Directory -Force $projects | Out-Null
    Write-Output "  added      folder  $projects"
}
try {
    foreach ($dir in $dirs) {
        $installed = Get-ThemePluginVersion $dir
        $parsed = $null
        if ($installed -and [version]::TryParse($installed, [ref]$parsed) -and $parsed -lt [version]$package.version) { Update-ThemePlugin $dir $installed }
        elseif (Test-ThemePlugin $dir) { Write-Output "  unchanged  $($dir.Name)  plugins\$($package.folder)" }
        else { Install-ThemePlugin $dir }
        # the IDE's own installPlugins can leave its download beside its system files. it is only
        # cleared once the plugin is unpacked at the pinned version, so nothing still needed goes
        if ((Get-ThemePluginVersion $dir) -eq $package.version) {
            foreach ($zip in Get-ChildItem (Join-Path $env:LOCALAPPDATA "JetBrains\$($dir.Name)\plugins") -Filter "$($package.folder)*.zip" -ErrorAction SilentlyContinue) {
                Remove-Item -LiteralPath $zip.FullName -Force
                Write-Output "  removed    $($dir.Name)  $($zip.Name) left in its system plugins folder"
            }
        }
        foreach ($scheme in Get-ChildItem (Join-Path $folder 'colors') -Filter *.icls | Sort-Object Name) {
            Copy-Tracked $dir $scheme.FullName "colors\$($scheme.Name)"
        }
        Copy-Tracked $dir (Join-Path $folder 'file-templates\Class.java') 'fileTemplates\internal\Class.java'
        Copy-Tracked $dir (Join-Path $folder "keymaps\$keymap.xml") "keymaps\$keymap.xml"
        Set-ActiveKeymap $dir
        # Windows lists Geist Mono under its short family names, so the font files come from ..\options\windows
        foreach ($name in 'editor-font.xml', 'terminal-font.xml') {
            Copy-Tracked $dir (Join-Path $folder "options\windows\$name") "options\$name"
        }
        Set-ThemeFiles $dir
        Set-ProjectDirectory $dir
    }
} finally {
    if ($release) { Remove-Item $release -Force -ErrorAction SilentlyContinue }
}

Write-Output "Theme: $($wanted.Name)"
Write-Output 'Done. Start the IDEs to pick up the changes.'
