# =============================================================================
# Community tools and advanced utilities
# PowerShell equivalents of the mac/linux community functions. Some tools
# behave differently: extract uses Expand-Archive or 7z, clipboard uses
# Set-Clipboard/Get-Clipboard, DNS uses Resolve-DnsName, HTTP uses
# Invoke-RestMethod. cdf is omitted - no Finder equivalent on Windows.
# =============================================================================

# extract: unpack any archive without remembering the right flags.
# Requires 7-Zip (7z) for non-zip formats.
function extract {
    param([string]$file)
    if (-not (Test-Path $file)) { Write-Host "'$file' is not a valid file" -ForegroundColor Red; return }
    switch -Wildcard ($file) {
        "*.zip"     { Expand-Archive -Path $file -DestinationPath (Split-Path $file) }
        "*.tar.gz"  { tar -xzf $file }
        "*.tar.bz2" { tar -xjf $file }
        "*.tar.xz"  { tar -xJf $file }
        "*.tar"     { tar -xf $file }
        "*.7z"      { 7z x $file }
        "*.rar"     { 7z x $file }
        default     { Write-Host "Cannot extract '$file': format not recognised" -ForegroundColor Red }
    }
}

# dataurl: encode a file as a base64 data URL.
# I use this when I need to embed a small image or font directly in CSS.
function dataurl {
    param([string]$file)
    $bytes = [System.IO.File]::ReadAllBytes($file)
    $b64 = [System.Convert]::ToBase64String($bytes)
    $mime = "application/octet-stream"
    Write-Host "data:${mime};base64,$b64"
}

# targz: create a .tar.gz from a file or directory using Windows' built-in bsdtar.
function targz {
    param([string]$Path)
    tar -czf "$($Path.TrimEnd('\')).tar.gz" $Path
}

# gz: show the original size and gzip-compressed size of a file side by side.
function gz {
    param([string]$File)
    $orig = (Get-Item $File).Length
    $tmp = [System.IO.Path]::GetTempFileName()
    tar -czf $tmp $File
    $gzip = (Get-Item $tmp).Length
    Remove-Item $tmp
    $ratio = [Math]::Round($gzip * 100 / $orig, 1)
    Write-Host "orig: $orig bytes"
    Write-Host "gzip: $gzip bytes ($ratio%)"
}

# envup: load a .env file and export every variable into the current session.
# I use this when running scripts locally that read from environment variables.
function envup {
    param([string]$file = ".env")
    if (-not (Test-Path $file)) { Write-Host "No $file found" -ForegroundColor Red; return }
    Get-Content $file | Where-Object { $_ -notmatch '^\s*#' -and $_ -match '=' } | ForEach-Object {
        $parts = $_ -split '=', 2
        [System.Environment]::SetEnvironmentVariable($parts[0].Trim(), $parts[1].Trim(), "Process")
    }
    Write-Host "Loaded $file" -ForegroundColor Green
}

# digga: show all DNS records for a domain in a readable format
function digga {
    param([string]$domain)
    Resolve-DnsName $domain -Type ANY | Format-List
}

# dns-flush: flush the Windows DNS cache
function dns-flush {
    $result = ipconfig /flushdns 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to flush DNS cache" -ForegroundColor Red
    } else {
        Write-Host "DNS cache flushed" -ForegroundColor Green
    }
}

# Clipboard shortcuts
function clipcopy { $input | Set-Clipboard }
function paste    { Get-Clipboard }

# HTTP method shortcuts via Invoke-RestMethod
function GET    { Invoke-RestMethod -Uri $args[0] -Method Get    $args[1..99] }
function POST   { Invoke-RestMethod -Uri $args[0] -Method Post   $args[1..99] }
function PUT    { Invoke-RestMethod -Uri $args[0] -Method Put    $args[1..99] }
function DELETE { Invoke-RestMethod -Uri $args[0] -Method Delete $args[1..99] }
function HEAD   { Invoke-WebRequest -Uri $args[0] -Method Head   $args[1..99] }

# change-extension: batch rename file extensions in the current directory.
# Usage: change-extension erb haml
function change-extension {
    param([string]$old, [string]$new)
    Get-ChildItem "*.$old" | Rename-Item -NewName { $_.Name -replace "\.$old$", ".$new" }
}

# o: open a file or directory in the default app - defaults to the current directory
function o {
    param([string]$Path = ".")
    Invoke-Item $Path
}

# backup: copy a file to a timestamped .bak alongside it before I risk editing it
function backup {
    param([string]$File)
    Copy-Item $File "$File.bak.$(Get-Date -Format yyyyMMddHHmmss)"
}

# please: re-run the last command elevated - saves retyping it after an "access denied"
function please {
    $last = (Get-History -Count 1).CommandLine
    Start-Process powershell -Verb RunAs -ArgumentList "-NoExit", "-Command", $last
}
