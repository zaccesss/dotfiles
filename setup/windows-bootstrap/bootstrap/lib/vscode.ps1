# VS Code extensions from the dotfiles' editors\vscode folder. The list pins versions (name@1.2.3). A
# missing extension is installed at its latest version. An installed one older than its pin is
# brought up to the pin, while one at or above its pin is left alone: installing the pin would roll
# it back

# name@version for each pinned extension whose installed version is older than its pin. a check on
# the name alone left an old Zacess Themes in place under a newer pin
function Get-OutdatedExtensions {
    param([string]$ListPath, [string[]]$Installed)

    $have = @{}
    foreach ($entry in $Installed) {
        $name, $version = $entry -split '@', 2
        if ($version) { $have[$name.Trim().ToLowerInvariant()] = $version.Trim() }
    }
    return @(Get-Content $ListPath |
        Where-Object { $_ -and $_ -notmatch '^\s*(//|#)' } |
        ForEach-Object {
            $name, $pin = $_.Trim() -split '@', 2
            $name = $name.ToLowerInvariant()
            $pinned = $null; $current = $null
            if ($pin -and $have.ContainsKey($name) -and
                [version]::TryParse($pin, [ref]$pinned) -and [version]::TryParse($have[$name], [ref]$current) -and
                $current -lt $pinned) { "$name@$pin" }
        })
}

function Get-WantedExtensions {
    param([string]$ListPath)

    return @(Get-Content $ListPath |
        Where-Object { $_ -and $_ -notmatch '^\s*(//|#)' } |
        ForEach-Object { ($_ -split '@')[0].Trim().ToLowerInvariant() } |
        Where-Object { $_ })
}

function Install-VSCodeExtensions {
    $repo = Join-Path $script:DotfilesDir 'editors\vscode'
    Get-Dotfiles

    $list = Join-Path $repo 'extensions.txt'
    if ($script:PlanMode -and -not (Test-Path $list)) {
        Write-Info "Would install missing VS Code extensions listed in $list"
        return
    }

    if (-not (Test-Command 'code')) {
        Write-Warn 'The code command is not on PATH yet; open a new terminal after the winget stage and run the bootstrap again'
        return
    }

    $wanted = Get-WantedExtensions -ListPath $list
    $versions = @(code --list-extensions --show-versions)
    $installed = @($versions | ForEach-Object { ($_ -split '@')[0].ToLowerInvariant() })
    $outdated = Get-OutdatedExtensions -ListPath $list -Installed $versions
    $missing = @($wanted | Where-Object { $installed -notcontains $_ })

    if ($missing.Count -eq 0 -and $outdated.Count -eq 0) {
        Write-Ok "All $($wanted.Count) VS Code extensions are installed at their pinned version or newer"
        return
    }

    foreach ($extension in $missing) {
        Invoke-Step "install the VS Code extension $extension" { code --install-extension $extension | Out-Null }
    }
    foreach ($extension in $outdated) {
        Invoke-Step "update the VS Code extension $extension" { code --install-extension $extension --force | Out-Null }
    }
}
