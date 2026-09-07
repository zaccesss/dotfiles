# =============================================================================
# Shell scripting tools - Windows PowerShell
# shellcheck via scoop: scoop install shellcheck
# PSScriptAnalyzer for PowerShell linting: Install-Module PSScriptAnalyzer
# =============================================================================

# shck: run shellcheck on a .sh file or find all .sh files in the current dir
# sc is reserved for sc.exe (Windows Service Control Manager)
function shck {
    if ($args.Count -gt 0) {
        shellcheck @args
    } else {
        Get-ChildItem -Recurse -Filter "*.sh" | ForEach-Object { shellcheck $_.FullName }
    }
}

# psanalyse: lint a .ps1 file with PSScriptAnalyzer
function psanalyse {
    param([string]$Path = ".")
    Invoke-ScriptAnalyzer -Path $Path -Recurse
}

# psanalysefix: auto-fix PSScriptAnalyzer warnings
function psanalysefix {
    param([string]$File)
    Invoke-Formatter -ScriptDefinition (Get-Content $File -Raw) | Set-Content $File
}

# sfmt: format shell scripts with shfmt (if installed via scoop)
function sfmt {
    param([string]$File)
    shfmt -i 4 -w $File
}

# bashn/zshn: syntax-check a bash/zsh script without running it, via WSL - there's
# no native Windows bash or zsh to run this against directly
function bashn { param([string]$File) wsl bash -n $File }
function zshn  { param([string]$File) wsl zsh -n $File }

# scwatch: run shellcheck every time a .sh file changes - polls instead of using a
# FileSystemWatcher event, simpler to reason about for an interactive shortcut
function scwatch {
    param([string]$Path = ".")
    Write-Host "Watching $Path for .sh changes... Ctrl+C to stop"
    $lastRun = Get-Date
    while ($true) {
        $changed = Get-ChildItem -Path $Path -Filter "*.sh" -Recurse | Where-Object { $_.LastWriteTime -gt $lastRun }
        if ($changed) {
            $lastRun = Get-Date
            $changed | ForEach-Object { shellcheck $_.FullName }
        }
        Start-Sleep -Seconds 2
    }
}
