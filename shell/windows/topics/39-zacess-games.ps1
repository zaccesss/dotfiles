# =============================================================================
# Zacess Games
# fourteen small original terminal games in the Zacess theme zt last set.
# apps\zacess-games\setup.ps1 installs the newest release binary.
#   zg                    the menu
#   zg <game>             one game: stackline, merge-gates, termle, signal, trace, drift,
#                         rooms, relay, through-ball, slipstream, array-guard, heatsink,
#                         touch-typing or learn-to-code
#   zg list               every game with its best score
#   zg sounds [game]      plays every effect, then each game's music
#   zg snap [game]        SVG stills of the games
#   zg --help             every option, such as --reduced-motion, --volume and --music-volume
# + and - set the effects, [ and ] the music and 0 mutes; effects start at 35 and music at 20.
# docs/controls.md in the zacesshq/games repository lists every key
# =============================================================================

# zt keeps its theme in %LOCALAPPDATA%\zacess\theme on Windows, where the games do not look, so
# the theme is handed over in ZACESS_THEME as the Zacess Scenes commands do
function zg {
    if (-not (Get-Command zacess-games -ErrorAction SilentlyContinue)) {
        Write-Error "zacess-games is not installed: & `"$env:DOTFILES\..\apps\zacess-games\setup.ps1`""
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
        try { & zacess-games @args } finally { Remove-Item Env:ZACESS_THEME -ErrorAction SilentlyContinue }
    } else {
        & zacess-games @args
    }
}

# the full name, as with zt and zs
function zacess-game { zg @args }

# Tab completes the game names and subcommands
$script:ZacessGamesWords = @('stackline', 'merge-gates', 'termle', 'signal', 'trace', 'drift', 'rooms', 'relay', 'through-ball', 'slipstream', 'array-guard', 'heatsink', 'touch-typing', 'learn-to-code', 'list', 'sounds', 'snap', 'menu', '--help')
Register-ArgumentCompleter -CommandName zg, zacess-game, zacess-games -Native -ScriptBlock {
    param($wordToComplete)
    $script:ZacessGamesWords | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
