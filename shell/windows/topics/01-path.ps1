# =============================================================================
# PATH configuration
# Adds user-managed tool locations to the front of PATH so user scripts take
# priority over system tools.
# =============================================================================

$env:PATH = "$HOME\.local\bin;$env:PATH"

# LibreOffice's installer leaves its program folder off PATH, so soffice (headless document
# conversion) is only found once it is added. it goes last because the folder also holds
# LibreOffice's own python.exe, which must not shadow the real Python
if ($env:ProgramFiles) {
    $libreOffice = Join-Path $env:ProgramFiles 'LibreOffice\program'
    if (Test-Path $libreOffice) { $env:PATH = "$env:PATH;$libreOffice" }
}
