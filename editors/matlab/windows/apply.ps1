# sets MATLAB's desktop theme, syntax colours and code font to one of the Zacess themes.
# usage: .\apply.ps1 [-Theme <theme>] [-Matlab <path to matlab.exe>]
#
# -Theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark.
#
# ..\shared\zacess_apply.m writes the theme and fonts through MATLAB's own settings API, which
# reaches the light theme's colours only. the theme's colour scheme in ..\shared\schemes is then
# applied with import_scheme from MathWorks' Color Theme Extensions add-on, which sets either
# theme's colours, editor text and background included. the add-on is fetched at the commit pinned
# in ..\shared\scheme-tools.json and checked against its digests. it needs the full desktop and
# MATLAB saves settings only when a session exits normally, so the script starts MATLAB minimised,
# applies both and quits (about a minute). nothing is backed up: the repo holds every value this
# writes.
param(
    [string]$Theme = 'deep-dark',
    [string]$Matlab
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
# a running MATLAB writes its own settings back on exit, over the ones written here
if (Get-Process -Name 'MATLAB' -ErrorAction SilentlyContinue) {
    [Console]::Error.WriteLine('MATLAB is running. Quit it first, then run this again.')
    exit 1
}

$themeFile = Join-Path $shared "themes\$name.json"
$schemeFile = Join-Path $shared "schemes\$name.json"
$fontFile = Join-Path $PSScriptRoot 'fonts.json'
# the start folder, ~/dev/projects/matlab on every OS, made when it is missing
$folderFile = Join-Path $shared 'folders.json'
# a run stopped by hand never reaches its clean-up, so any earlier work folder is cleared here
Get-ChildItem ([IO.Path]::GetTempPath()) -Directory -Filter 'zacess-matlab-*' -ErrorAction SilentlyContinue |
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
$work = Join-Path ([IO.Path]::GetTempPath()) "zacess-matlab-$PID"
$log = Join-Path $work 'matlab.log'
try {
    New-Item -ItemType Directory -Force (Join-Path $work 'tools') | Out-Null
    $tools = Get-Content (Join-Path $shared 'scheme-tools.json') -Raw | ConvertFrom-Json
    $base = $tools.repository -replace '^https://github.com/', 'https://raw.githubusercontent.com/'
    foreach ($file in $tools.files.PSObject.Properties) {
        $dest = Join-Path $work "tools\$($file.Name)"
        Invoke-WebRequest -Uri "$base/$($tools.commit)/$($file.Name)" -OutFile $dest -UseBasicParsing
        if ((Get-FileHash $dest -Algorithm SHA256).Hash -ne $file.Value) {
            [Console]::Error.WriteLine("$($file.Name) from the Color Theme Extensions add-on does not match its pinned digest, so nothing was applied.")
            exit 1
        }
    }
    $command = "addpath('$shared'); addpath('$work\tools'); zacess_apply('$themeFile', '$fontFile', '$folderFile'); " +
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
