# =============================================================================
# Zacess Scenes
# calm animated scenes in the terminal in the Zacess theme zt last set, plus a build watcher.
# apps\zacess-scenes\setup.ps1 installs the program and bacon and links scenes.toml.
#   zs                    a random calm scene, then another every five minutes
#   zs <scene>            one scene by name (zs list shows them all)
#   zs list               every scene and sound set
#   zs sounds [set] [event]  one sound set; with no set, every set's pass tone in turn
#   zs config             open scenes.toml in $env:EDITOR
#   zs new <name>         start a Lua scene of your own
#   zs snap <scene>       an SVG still of a scene
#   zs themes             the themes and which one is active
#   zsf                   follow the shells in this tmux session: calm while commands work
#   zw                    watch the project here, in any language, rerun on each save
#   zwc / zwt / zwa       watch a Rust build with bacon: clippy, test, check-all
# =============================================================================

# zt keeps its theme in %LOCALAPPDATA%\zacess\theme on Windows, where Zacess Scenes does not look,
# so the theme is handed over in ZACESS_THEME. "auto <dark> <light>" follows the Windows app mode
function Invoke-ZacessScenes {
    if (-not (Get-Command zacess-scenes -ErrorAction SilentlyContinue)) {
        Write-Error "zacess-scenes is not installed: & `"$env:DOTFILES\..\apps\zacess-scenes\setup.ps1`""
        return
    }
    $state = Join-Path $env:LOCALAPPDATA 'zacess\theme'
    $theme = $null
    if (-not $env:ZACESS_THEME -and [IO.File]::Exists($state)) {
        $words = ([IO.File]::ReadAllText($state)).Trim() -split '\s+'
        if ($words[0] -eq 'auto' -and $words.Count -ge 3) {
            $light = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -ErrorAction SilentlyContinue).AppsUseLightTheme
            $theme = if ($light -eq 1) { $words[2] } else { $words[1] }
        } elseif ($words[0]) {
            $theme = $words[0]
        }
    }
    if ($theme) {
        $env:ZACESS_THEME = $theme
        try { & zacess-scenes @args } finally { Remove-Item Env:ZACESS_THEME -ErrorAction SilentlyContinue }
    } else {
        & zacess-scenes @args
    }
}

function zs {
    switch ($args[0]) {
        $null {
            # the original and pass scenes are the calm ones; fail scenes are left for failures
            $calm = @(zacess-scenes list | ForEach-Object { $f = -split $_; if ($f.Count -ge 2 -and ($f[1] -eq 'pass' -or $f[1] -eq 'general')) { $f[0] } })
            $pick = if ($calm.Count) { $calm | Get-Random } else { 'sea' }
            Invoke-ZacessScenes $pick --shuffle
        }
        'sounds' {
            $rest = @($args | Select-Object -Skip 1)
            if ($rest.Count) {
                Invoke-ZacessScenes sounds play @rest
            } else {
                $on = $false
                foreach ($line in (zacess-scenes list)) {
                    if ($line -like 'Sound sets*') { $on = $true; continue }
                    $set = (-split $line)[0]
                    if ($on -and $set -and $set -ne 'Events:') {
                        $set
                        Invoke-ZacessScenes sounds play $set
                        Start-Sleep -Milliseconds 1500
                    }
                }
            }
        }
        'config' { $editor = if ($env:EDITOR) { $env:EDITOR } else { 'code' }; & $editor (zacess-scenes config path) }
        'new' { Invoke-ZacessScenes scene new @($args | Select-Object -Skip 1) }
        'snap' { Invoke-ZacessScenes snapshot @($args | Select-Object -Skip 1) }
        'themes' { Invoke-ZacessScenes --list-themes }
        default { Invoke-ZacessScenes @args }
    }
}

# the full name, as with zt and zacess-theme
function zacess-scene { zs @args }

function zsf { Invoke-ZacessScenes follow @args }
function zw { Invoke-ZacessScenes watch @args }
function zwc { Invoke-ZacessScenes watch clippy @args }
function zwt { Invoke-ZacessScenes watch test @args }
function zwa { Invoke-ZacessScenes watch check-all @args }

# a scene running zacess-scenes follow shows how each command in this shell ended. The hook wraps
# the prompt set up before it, so it loads after the prompt topic; an older zacess-scenes without
# follow mode prints nothing here
if (Get-Command zacess-scenes -ErrorAction SilentlyContinue) {
    $zacessFollowInit = zacess-scenes follow init powershell 2>$null | Out-String
    if ($LASTEXITCODE -eq 0 -and $zacessFollowInit.Trim()) { Invoke-Expression $zacessFollowInit }
    Remove-Variable zacessFollowInit -ErrorAction SilentlyContinue
}
