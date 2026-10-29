# sets MATLAB's desktop theme, syntax colours and code font to one of the Zacess themes.
# usage: .\apply.ps1 [-Theme <theme>] [-Matlab <path to matlab.exe>] [-Pending]
#
# -Theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark.
#
# ..\shared\zacess_apply.m writes the theme and fonts through MATLAB's own settings API, which
# reaches the light theme's colours only. the theme's colour scheme in ..\shared\schemes is then
# applied with import_scheme from MathWorks' Color Theme Extensions add-on, which sets either
# theme's colours, editor text and background included. the add-on is kept in
# %LOCALAPPDATA%\zacess\matlab-tools at the commit pinned in ..\shared\scheme-tools.json and checked
# against its digests.
#
# every run also adds a marked block to startup.m in MATLAB's userpath (Documents\MATLAB), leaving
# the file's other lines as they are. the block runs ..\shared\zacess_startup.m, which applies a
# theme named in %LOCALAPPDATA%\zacess\matlab-theme on MATLAB's next start and removes that file.
#
# -Pending only writes that file, so nothing starts: zt uses it to stay instant. without it the
# script starts MATLAB minimised, applies the theme and quits (about a minute), since the add-on
# needs the full desktop and MATLAB saves settings only when a session exits normally. nothing is
# backed up: the repo holds every value this writes.
param(
    [string]$Theme = 'deep-dark',
    [string]$Matlab,
    [switch]$Pending
)

$ErrorActionPreference = 'Stop'
$shared = (Resolve-Path (Join-Path $PSScriptRoot '..\shared')).Path

$themeNames = [ordered]@{
    'deep-dark' = 'Zacess Deep Contrast Dark'; 'deep-contrast-dark' = 'Zacess Deep Contrast Dark'
    'deep-light' = 'Zacess Deep Contrast Light'; 'deep-contrast-light' = 'Zacess Deep Contrast Light'
    'hc-dark' = 'Zacess High Contrast Dark'; 'high-contrast-dark' = 'Zacess High Contrast Dark'
    'hc-light' = 'Zacess High Contrast Light'; 'high-contrast-light' = 'Zacess High Contrast Light'
    'dark' = 'Zacess Dark'; 'light' = 'Zacess Light'; 'cream' = 'Zacess Cream'
    'yellow' = 'Zacess Yellow on Black'; 'yellow-on-black' = 'Zacess Yellow on Black'
}
$key = ($Theme.ToLowerInvariant() -replace '^zacess[ -]', '') -replace ' ', '-'
$name = $themeNames[$key]
if (-not $name) {
    [Console]::Error.WriteLine("Unknown theme: $Theme")
    [Console]::Error.WriteLine('Pick one of deep-dark, deep-light, hc-dark, hc-light, dark, light, cream or yellow.')
    exit 1
}

if (-not $Matlab) {
    $Matlab = Get-ChildItem 'C:\Program Files\MATLAB' -Directory -Filter 'R20*' -ErrorAction SilentlyContinue |
        Sort-Object Name -Descending | ForEach-Object { Join-Path $_.FullName 'bin\matlab.exe' } |
        Where-Object { Test-Path $_ } | Select-Object -First 1
}
if (-not $Matlab -or -not (Test-Path $Matlab)) {
    [Console]::Error.WriteLine('No MATLAB found. Pass -Matlab with the path to matlab.exe.')
    exit 1
}
# a running MATLAB writes its own settings back on exit, over the ones written here. a pending
# theme is only read at the next start, so it can be left while MATLAB is open
if (-not $Pending -and (Get-Process -Name 'MATLAB' -ErrorAction SilentlyContinue)) {
    [Console]::Error.WriteLine('MATLAB is running. Quit it first, then run this again.')
    exit 1
}

$themeFile = Join-Path $shared "themes\$name.json"
$schemeFile = Join-Path $shared "schemes\$name.json"
$fontFile = Join-Path $PSScriptRoot 'fonts.json'
# the start folder, ~/dev/projects/matlab on every OS, made when it is missing
$folderFile = Join-Path $shared 'folders.json'
$state = Join-Path $env:LOCALAPPDATA 'zacess'
$pendingFile = Join-Path $state 'matlab-theme'
$toolsDir = Join-Path $state 'matlab-tools'
$startup = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'MATLAB\startup.m'

# the add-on, fetched only when a file is missing or does not match its pinned digest
$tools = Get-Content (Join-Path $shared 'scheme-tools.json') -Raw | ConvertFrom-Json
$base = $tools.repository -replace '^https://github.com/', 'https://raw.githubusercontent.com/'
New-Item -ItemType Directory -Force $toolsDir | Out-Null
foreach ($file in $tools.files.PSObject.Properties) {
    $dest = Join-Path $toolsDir $file.Name
    if ((Test-Path $dest) -and (Get-FileHash $dest -Algorithm SHA256).Hash -eq $file.Value) {
        Write-Output "  unchanged  tools     $($file.Name)"
        continue
    }
    Invoke-WebRequest -Uri "$base/$($tools.commit)/$($file.Name)" -OutFile $dest -UseBasicParsing
    if ((Get-FileHash $dest -Algorithm SHA256).Hash -ne $file.Value) {
        Remove-Item $dest -Force
        [Console]::Error.WriteLine("$($file.Name) from the Color Theme Extensions add-on does not match its pinned digest, so nothing was applied.")
        exit 1
    }
    Write-Output "  added      tools     $($file.Name)"
}

# the startup.m block, between its two marker lines. MATLAB strings double a quote to escape it
$quote = { param($path) "'" + $path.Replace("'", "''") + "'" }
$block = @(
    '% >>> zacess theme: added by the dotfiles MATLAB apply script, applies a theme zt left for this start'
    "try, addpath($(& $quote $shared)); zacess_startup($(& $quote $pendingFile), $(& $quote $toolsDir), $(& $quote $fontFile), $(& $quote $folderFile)); catch zacessError, warning('zacess:startup', '%s', zacessError.message); end; clear zacessError"
    '% <<< zacess theme'
) -join "`r`n"
$text = if (Test-Path $startup) { [IO.File]::ReadAllText($startup) } else { '' }
$marked = [regex]::Match($text, '(?s)% >>> zacess theme.*?% <<< zacess theme')
$new = if ($marked.Success) { $text.Substring(0, $marked.Index) + $block + $text.Substring($marked.Index + $marked.Length) }
       elseif ($text) { $text.TrimEnd() + "`r`n`r`n" + $block + "`r`n" }
       else { $block + "`r`n" }
if ($new -ceq $text) {
    Write-Output "  unchanged  startup   $startup"
} else {
    New-Item -ItemType Directory -Force (Split-Path $startup) | Out-Null
    [IO.File]::WriteAllText($startup, $new, (New-Object Text.UTF8Encoding $false))
    Write-Output "  $(if ($text) { 'changed  ' } else { 'added    ' })  startup   $startup"
}

if ($Pending) {
    New-Item -ItemType Directory -Force $state | Out-Null
    $old = if (Test-Path $pendingFile) { ([IO.File]::ReadAllText($pendingFile)).Trim() }
    if ($old -eq $name) {
        Write-Output "  waiting    pending   $name"
    } else {
        [IO.File]::WriteAllText($pendingFile, $name)
        Write-Output "  changed    pending   $name"
    }
    Write-Output "Theme: $name, on MATLAB's next start"
    exit 0
}

# a run stopped by hand never reaches its clean-up, so any earlier work folder is cleared here
Get-ChildItem ([IO.Path]::GetTempPath()) -Directory -Filter 'zacess-matlab-*' -ErrorAction SilentlyContinue |
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
$work = Join-Path ([IO.Path]::GetTempPath()) "zacess-matlab-$PID"
$log = Join-Path $work 'matlab.log'
try {
    New-Item -ItemType Directory -Force $work | Out-Null
    # the theme is applied here and now, so a pending one would be applied over it at the next start
    Remove-Item $pendingFile -Force -ErrorAction SilentlyContinue
    $command = "addpath('$shared'); addpath('$toolsDir'); zacess_apply('$themeFile', '$fontFile', '$folderFile'); " +
        "try, import_scheme('$schemeFile'); fprintf('  applied    scheme    $name\n'); catch e, fprintf('  failed     scheme    %s\n', e.message); end; exit"
    # Start-Process -Wait also waits for every process MATLAB started, so a crash reporter left
    # running after MATLAB has exited held the run for good. Only the launcher is waited on
    $process = Start-Process -FilePath $Matlab -ArgumentList '-nosplash', '-wait', '-logfile', "`"$log`"", '-r', "`"$command`"" -PassThru -WindowStyle Minimized
    if (-not $process.WaitForExit(600000)) {
        [Console]::Error.WriteLine('MATLAB did not exit within ten minutes. Close it by hand; the settings in the log below were written.')
    }
    $lines = if (Test-Path $log) { Get-Content $log | Where-Object { $_ -match '^\s+(added|changed|unchanged|applied|failed)\s' } } else { @() }
} finally {
    Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue
}
if (-not $lines) {
    [Console]::Error.WriteLine('MATLAB ran but reported no settings. Run it by hand to see the error.')
    exit 1
}
$lines
if ($lines -match '^\s+failed') { exit 1 }
Write-Output "Theme: $name"
Write-Output 'Done. Start MATLAB to see it.'
