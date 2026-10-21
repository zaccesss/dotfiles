# the PowerShell profile's welcome banner for Command Prompt, run by autorun.cmd. the colours are
# SGR codes for the terminal's own 16 colour slots, so the banner follows any terminal theme
$e = [char]27
$nt = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
# ProductName still says Windows 10 on Windows 11, so the build number decides
$os = if ([int]$nt.CurrentBuild -ge 22000) { 'Windows 11' } else { 'Windows 10' }
$edition = @{ Professional = 'Pro'; Core = 'Home'; Enterprise = 'Enterprise'; Education = 'Education' }[$nt.EditionID]
if ($edition) { $os = "$os $edition" }
$version = [Environment]::OSVersion.Version
Write-Host ""
Write-Host "─ $e[1;36mWelcome back, Isaac$e[0m ───────────────────────"
Write-Host "  Machine   $e[0;32m$([Environment]::MachineName), $os$e[0m"
Write-Host "  Shell     $e[0;35mCommand Prompt $($version.Major).$($version.Minor).$($version.Build)$e[0m"
Write-Host "  Session   $e[1;33m$(Get-Date -Format 'ddd dd MMM yyyy, HH:mm')$e[0m"
Write-Host "─────────────────────────────────────────────"
Write-Host ""
