# imports one Zacess theme (fonts and colours) into Microchip Studio 7.
# usage: .\apply.ps1 [-Theme <theme>] [-Studio <path to AtmelStudio.exe>] [-Close] [-Pending]
#
# -Theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark.
#
# Microchip Studio reads colours only through its own Import and Export Settings command, so the
# script starts Studio with that command and the chosen ..\themes\<name>.vssettings. the file
# holds only the Fonts and Colors category, so every other setting is left as it was. nothing is
# backed up: the repo holds every value it imports.
#
# the theme file also becomes Studio's team settings file (Tools > Options > Environment > Import
# and Export Settings), which Studio imports by itself at its next start whenever the file is newer
# than the time it last imported it. -Pending only points the team settings file at the theme and
# clears that time, so Studio is not started: zt uses it to stay instant. a direct run imports at
# once and records the file's time, so the next start does not import it again.
param(
    [string]$Theme = 'deep-dark',
    [string]$Studio = 'C:\Program Files (x86)\Atmel\Studio\7.0\AtmelStudio.exe',
    # closes Studio once the import is confirmed, so nothing is left open
    [switch]$Close,
    [switch]$Pending
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

# Visual Studio's team settings values: the file, whether it is tracked and the file's UTC write
# time as a FILETIME split in two, which Studio sets once it has imported the file
$profileKey = Join-Path $studioKey 'Profile'
$teamFile = (Resolve-Path (Join-Path $themes "$name.vssettings")).Path
function Set-TeamSettings([int64]$Imported) {
    if (-not (Test-Path $profileKey)) { New-Item -Path $profileKey -Force | Out-Null }
    $bytes = [BitConverter]::GetBytes($Imported)
    Set-ItemProperty -Path $profileKey -Name TeamSettingsFile -Value $teamFile
    Set-ItemProperty -Path $profileKey -Name TrackTeamSettings -Value 1 -Type DWord
    Set-ItemProperty -Path $profileKey -Name TeamSettingsFILETIMELow -Value ([BitConverter]::ToInt32($bytes, 0)) -Type DWord
    Set-ItemProperty -Path $profileKey -Name TeamSettingsFILETIMEHigh -Value ([BitConverter]::ToInt32($bytes, 4)) -Type DWord
}

if ($Pending) {
    # Studio writes its profile back as it exits, so a change made while it is open could be lost
    if (Get-Process -Name 'AtmelStudio' -ErrorAction SilentlyContinue) {
        [Console]::Error.WriteLine('Microchip Studio is running. Quit it first, then run this again.')
        exit 1
    }
    $current = Get-ItemProperty -Path $profileKey -ErrorAction SilentlyContinue
    if ($current -and $current.TrackTeamSettings -eq 1 -and $current.TeamSettingsFile -eq $teamFile) {
        $stored = ([int64][uint32]$current.TeamSettingsFILETIMEHigh -shl 32) -bor [int64][uint32]$current.TeamSettingsFILETIMELow
        $status = if ($stored -eq (Get-Item $teamFile).LastWriteTimeUtc.ToFileTimeUtc()) { 'unchanged' } else { 'waiting  ' }
        Write-Output "  $status  registry  TeamSettingsFile $name"
    } else {
        Set-TeamSettings 0
        Write-Output "  changed    registry  TeamSettingsFile $name"
    }
    Write-Output "Theme: $name, on Microchip Studio's next start"
    exit 0
}

# the import below is the one that counts, so the team settings file is marked as already imported
Set-TeamSettings ((Get-Item $teamFile).LastWriteTimeUtc.ToFileTimeUtc())

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
