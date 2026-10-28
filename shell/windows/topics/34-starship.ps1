# initialise Starship prompt. starship's own init line starts starship twice on every new terminal,
# so the full init script it prints is cached by _cachedInit (06-functions) and only made again
# after an upgrade or a change to starship.toml. without starship the plain prompt from 02-colours stays
$starship = Get-Command starship -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
if ($starship) {
    $starshipConfig = if ($env:STARSHIP_CONFIG) { $env:STARSHIP_CONFIG } else { Join-Path $HOME '.config/starship.toml' }
    $starshipInit = _cachedInit starship $starship.Source @('init', 'powershell', '--print-full-init') -DependsOn $starshipConfig -Transform {
        param($script)
        # the init script starts starship once more on every new terminal just to read the
        # continuation prompt, which costs about half a second on Windows. that text only changes
        # with starship.toml, so it is read once here and written into the cached script instead
        # starship formats the text for the shell named in STARSHIP_SHELL, which the init script
        # only sets later, so it is set here for this one call
        $shell = $env:STARSHIP_SHELL
        $env:STARSHIP_SHELL = 'powershell'
        $continuation = (& $starship.Source prompt --continuation | Out-String).TrimEnd("`r", "`n")
        $env:STARSHIP_SHELL = $shell
        $literal = "'" + $continuation.Replace("'", "''") + "'"
        $pattern = '(?s)(Set-PSReadLineOption -ContinuationPrompt )\(\s*Invoke-Native -Executable .*?"--continuation"\s*\)\s*\)'
        [regex]::Replace($script, $pattern, { param($m) $m.Groups[1].Value + $literal })
    }
    if ($starshipInit) { . $starshipInit }
}
