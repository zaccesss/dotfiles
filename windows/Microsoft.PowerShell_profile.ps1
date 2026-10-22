# temporary forwarding file: the real one moved to shell/. removed in a later release, once
# a machine has had time to re-run its bootstrap
$env:DOTFILES = (Resolve-Path (Join-Path $PSScriptRoot '..\shell')).Path
# a tool that runs powershell.exe -Command reads everything printed as its result, so the notice
# only shows in an interactive window, the same test the real profile uses
$batch = [Environment]::GetCommandLineArgs() | Where-Object { $_ -match '^[-/](c|co|com|comm|comma|comman|command|f|fi|fil|file|e|ec|en|enc\w*|noni\w*)$' }
if (-not $env:DOTFILES_MOVED_SHOWN -and -not $batch -and -not [Console]::IsOutputRedirected) {
    Write-Host "dotfiles moved to shell/: run setup/windows-bootstrap to re-point" -ForegroundColor Yellow
    $env:DOTFILES_MOVED_SHOWN = '1'
}
. (Join-Path $env:DOTFILES 'windows\Microsoft.PowerShell_profile.ps1')
