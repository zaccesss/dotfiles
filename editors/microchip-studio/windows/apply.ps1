# imports one Zacess theme (fonts and colours) into Microchip Studio 7.
# usage: .\apply.ps1 [-Theme <theme>] [-Studio <path to AtmelStudio.exe>] [-Close]
#
# -Theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark.
#
# Microchip Studio reads colours only through its own Import and Export Settings command, so the
# script starts Studio with that command and the chosen ..\themes\<name>.vssettings. the file
# holds only the Fonts and Colors category, so every other setting is left as it was. nothing is
# backed up: the repo holds every value it imports.
param(
    [string]$Theme = 'deep-dark',
    [string]$Studio = 'C:\Program Files (x86)\Atmel\Studio\7.0\AtmelStudio.exe',
    # closes Studio once the import is confirmed, as zt does, so nothing is left open
    [switch]$Close
)

$ErrorActionPreference = 'Stop'
$themes = Join-Path $PSScriptRoot '..\themes'

$themeNames = [ordered]@{
    'deep-dark' = @('Zacess Deep Contrast Dark', 'dark'); 'deep-contrast-dark' = @('Zacess Deep Contrast Dark', 'dark')
    'deep-light' = @('Zacess Deep Contrast Light', 'light'); 'deep-contrast-light' = @('Zacess Deep Contrast Light', 'light')
    'hc-dark' = @('Zacess High Contrast Dark', 'dark'); 'high-contrast-dark' = @('Zacess High Contrast Dark', 'dark')
    'hc-light' = @('Zacess High Contrast Light', 'light'); 'high-contrast-light' = @('Zacess High Contrast Light', 'light')
    'dark' = @('Zacess Dark', 'dark'); 'light' = @('Zacess Light', 'light'); 'cream' = @('Zacess Cream', 'light')
    'yellow' = @('Zacess Yellow on Black', 'dark'); 'yellow-on-black' = @('Zacess Yellow on Black', 'dark')
}
$key = ($Theme.ToLowerInvariant() -replace '^zacess[ -]', '') -replace ' ', '-'
$picked = $themeNames[$key]
if (-not $picked) {
    [Console]::Error.WriteLine("Unknown theme: $Theme")
    [Console]::Error.WriteLine('Pick one of deep-dark, deep-light, hc-dark, hc-light, dark, light, cream or yellow.')
    exit 1
}
$name, $mode = $picked
# the Visual Studio 2015 environment theme the import switches to, read back to confirm it took
$vsTheme = @{ dark = '1ded0138-47ce-435e-84ef-9ec1f439b749'; light = 'de3dbbcd-f642-433c-8353-8f1df4370aba' }[$mode]

if (-not (Test-Path $Studio)) {
    [Console]::Error.WriteLine("No Microchip Studio at $Studio. Pass -Studio with the path to AtmelStudio.exe.")
    exit 1
}
# an import into a running Studio would be overwritten when it exits
if (Get-Process -Name 'AtmelStudio' -ErrorAction SilentlyContinue) {
    [Console]::Error.WriteLine('Microchip Studio is running. Quit it first, then run this again.')
    exit 1
}

# new projects go in ~\dev\projects\avr, the projects folder every editor shares. Studio reads both
# values at start, so they are written before it starts; the open-project folder is left as it is
$projects = Join-Path $env:USERPROFILE 'dev\projects\avr'
if (-not (Test-Path $projects)) {
    New-Item -ItemType Directory -Force $projects | Out-Null
    Write-Output "  added      folder  $projects"
}
$studioKey = 'HKCU:\Software\Atmel\AtmelStudio\7.0'
if (-not (Test-Path $studioKey)) { New-Item -Path $studioKey -Force | Out-Null }
foreach ($valueName in 'DefaultNewProjectLocation', 'VisualStudioProjectsLocation') {
    $old = (Get-ItemProperty -Path $studioKey -Name $valueName -ErrorAction SilentlyContinue).$valueName
    $status = if ($null -eq $old) { 'added    ' } elseif ($old -eq $projects) { 'unchanged' } else { 'changed  ' }
    if ($old -ne $projects) { Set-ItemProperty -Path $studioKey -Name $valueName -Value $projects }
    Write-Output "  $status  registry  $valueName"
}

# the /Command argument cannot quote a path, so the theme goes to a temporary path with no spaces
# the file of an earlier run is cleared here: Studio may still have been reading it when that run ended
Get-ChildItem ([IO.Path]::GetTempPath()) -Filter 'zacess-microchip-theme-*.vssettings' -ErrorAction SilentlyContinue |
    Remove-Item -Force -ErrorAction SilentlyContinue
$import = Join-Path ([IO.Path]::GetTempPath()) "zacess-microchip-theme-$PID.vssettings"
Copy-Item (Join-Path $themes "$name.vssettings") $import -Force
try {
    $process = Start-Process -FilePath $Studio -ArgumentList "/Command `"Tools.ImportandExportSettings /import:$import`"" -PassThru
    # the command runs once the main window is up, so the theme is only read back after that. the
    # temporary file must stay until then
    for ($i = 0; $i -lt 90 -and -not (Get-Process -Id $process.Id -ErrorAction SilentlyContinue).MainWindowTitle; $i++) {
        Start-Sleep -Seconds 2
    }
    Start-Sleep -Seconds 5
    $themeKey = 'HKCU:\Software\Atmel\AtmelStudio\7.0\ApplicationPrivateSettings\Microsoft\VisualStudio'
    $done = $false
    for ($i = 0; $i -lt 30 -and -not $done; $i++) {
        Start-Sleep -Seconds 2
        $value = (Get-ItemProperty -Path $themeKey -Name ColorTheme -ErrorAction SilentlyContinue).ColorTheme
        $done = "$value" -match $vsTheme
    }
} catch {
    Remove-Item $import -Force -ErrorAction SilentlyContinue
    throw
}
if (-not $done) {
    [Console]::Error.WriteLine("Microchip Studio started but did not report the $mode environment theme within three minutes.")
    [Console]::Error.WriteLine('Check Tools > Options > Environment > Fonts and Colors.')
    exit 1
}
Write-Output "Imported $name into Microchip Studio, with its $mode environment theme."
if (-not $Close) {
    Write-Output 'Studio stays open; the fonts and colours are saved when it exits.'
    exit 0
}
# Studio saves the imported fonts and colours as it exits, so it is closed the way a user would
# close it and given time to finish writing
$null = $process.CloseMainWindow()
if (-not $process.WaitForExit(120000)) {
    [Console]::Error.WriteLine('Microchip Studio did not close within two minutes. Close it by hand so the theme is saved.')
    exit 1
}
Remove-Item $import -Force -ErrorAction SilentlyContinue
Write-Output 'Studio closed and saved the theme.'
