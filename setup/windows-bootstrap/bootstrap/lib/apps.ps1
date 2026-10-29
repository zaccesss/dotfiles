# the editors and apps whose settings come from an apply script of their own in the dotfiles.
# each runs only when its app is installed and closed, since an app writes its settings back on
# exit. each prints one line. the scripts change only their own keys and running one again changes
# nothing, so the stage is safe to repeat. MATLAB and Microchip Studio start briefly to apply a
# theme, so they take about a minute each
function Get-AppScripts {
    $programFiles = [Environment]::GetFolderPath('ProgramFiles')
    $programFilesX86 = [Environment]::GetFolderPath('ProgramFilesX86')
    $appData = [Environment]::GetFolderPath('ApplicationData')
    $localAppData = [Environment]::GetFolderPath('LocalApplicationData')
    $apps = @(
        @{ Name = 'Eclipse'; Script = 'editors\eclipse\apply.ps1'; Process = 'eclipse'
           Installed = { Test-Path (Join-Path $HOME 'eclipse-workspace\.metadata') } }
        @{ Name = 'STM32CubeIDE'; Script = 'editors\stm32cubeide\windows\apply.ps1'; Process = 'stm32cubeide'
           Installed = { Test-Path (Join-Path $HOME 'STM32CubeIDE') } }
        @{ Name = 'Arduino IDE'; Script = 'editors\arduino\windows\apply.ps1'; Process = 'Arduino IDE'
           Installed = { Test-Path (Join-Path $HOME '.arduinoIDE\settings.json') } }
        @{ Name = 'Microchip Studio'; Script = 'editors\microchip-studio\windows\apply.ps1'; Process = 'AtmelStudio'; Extra = @('-Close')
           Installed = { Test-Path (Join-Path $programFilesX86 'Atmel\Studio\7.0\AtmelStudio.exe') } }
        @{ Name = 'KiCad'; Script = 'editors\kicad\windows\apply.ps1'; Process = 'kicad'
           Installed = { Test-Path (Join-Path $appData 'kicad') } }
        @{ Name = 'LTspice'; Script = 'editors\ltspice\windows\apply.ps1'; Process = 'LTspice'
           Installed = { (Test-Path (Join-Path $appData 'LTspice.ini')) -or (Test-Path (Join-Path $appData 'LTspiceXVII.ini')) } }
        @{ Name = 'MATLAB'; Script = 'editors\matlab\windows\apply.ps1'; Process = 'MATLAB'
           Installed = { [bool](Get-ChildItem (Join-Path $programFiles 'MATLAB') -Directory -Filter 'R20*' -ErrorAction SilentlyContinue) } }
        @{ Name = 'Notepad++'; Script = 'editors\notepad-plus-plus\windows\apply.ps1'; Process = 'notepad++'
           Installed = { Test-Path (Join-Path $appData 'Notepad++\config.xml') } }
        @{ Name = 'Processing'; Script = 'editors\processing\windows\apply.ps1'; Process = 'Processing'
           Installed = { Test-Path (Join-Path $appData 'Processing\preferences.txt') } }
        @{ Name = 'Proteus'; Script = 'editors\proteus\windows\apply.ps1'; Process = 'PDS'
           Installed = { Test-Path 'HKCU:\Software\Labcenter Electronics\Proteus 8 Professional\ARES' } }
        @{ Name = 'Thonny'; Script = 'editors\thonny\windows\apply.ps1'; Process = 'thonny'
           Installed = { Test-Path (Join-Path $appData 'Thonny\configuration.ini') } }
        @{ Name = 'Vivado'; Script = 'editors\vivado\windows\apply.ps1'; Process = 'vivado'
           Installed = { Test-Path (Join-Path $appData 'Xilinx\Vivado') } }
        # a vault can live anywhere, so it is named once in OBSIDIAN_VAULT, which zt and the apply
        # script read too
        @{ Name = 'Obsidian'; Script = 'apps\obsidian\windows\apply.ps1'; Process = 'Obsidian'
           Missing = 'not installed or no vault named in OBSIDIAN_VAULT'
           Installed = { (Test-Path (Join-Path $localAppData 'Programs\Obsidian\Obsidian.exe')) -and $env:OBSIDIAN_VAULT -and (Test-Path (Join-Path $env:OBSIDIAN_VAULT '.obsidian')) } }
        @{ Name = 'Zotero'; Script = 'apps\zotero\windows\apply.ps1'; Process = 'zotero'
           Installed = { Test-Path (Join-Path $appData 'Zotero\Zotero\Profiles') } }
        # Zacess Scenes installs its own release binary, so it needs no app to be present
        @{ Name = 'Zacess Scenes'; Script = 'apps\zacess-scenes\setup.ps1'; Process = $null
           Installed = { $true } }
        # Zacess Games installs its own release binary too
        @{ Name = 'Zacess Games'; Script = 'apps\zacess-games\setup.ps1'; Process = $null
           Installed = { $true } }
        # TranslucentTB reloads its settings file while it runs, so it is never skipped for being open
        @{ Name = 'TranslucentTB'; Script = 'apps\translucenttb\windows\apply.ps1'; Process = $null
           Installed = { Test-Path (Join-Path $localAppData 'Packages\28017CharlesMilette.TranslucentTB_v826wp6bftszj') } }
        # Zed reloads its settings and themes while it runs, so it is never skipped for being open
        @{ Name = 'Zed'; Script = 'editors\zed\windows\apply.ps1'; Process = $null
           Installed = { (Test-Path (Join-Path $appData 'Zed')) -or (Test-Path (Join-Path $localAppData 'Programs\Zed\Zed.exe')) } }
        # one script for every IDE: the theme plugin, the shared settings, the theme and ~\dev\projects
        # for new projects. an IDE has a config folder with options\ once it has been started
        @{ Name = 'JetBrains'; Script = 'editors\jetbrains\windows\apply.ps1'
           Process = @('idea64', 'pycharm64', 'webstorm64', 'clion64', 'dataspell64', 'goland64', 'phpstorm64', 'rubymine64', 'rustrover64', 'rider64', 'studio64')
           Installed = { [bool](Get-ChildItem (Join-Path $appData 'JetBrains') -Directory -ErrorAction SilentlyContinue | Where-Object { Test-Path (Join-Path $_.FullName 'options') }) } }
    )
    # each check runs later, after this function has returned, so it keeps the folder paths above
    foreach ($app in $apps) {
        $app.Installed = $app.Installed.GetNewClosure()
        if (-not $app.ContainsKey('Extra')) { $app.Extra = @() }
        if (-not $app.ContainsKey('Missing')) { $app.Missing = 'not installed' }
    }
    $apps
}

function Install-AppSettings {
    param([string]$Repo = $script:DotfilesDir)

    # pwsh runs the scripts, since several need PowerShell 7 and the bootstrap may run in 5.1
    $pwsh = (Get-Command pwsh -ErrorAction SilentlyContinue).Source
    foreach ($app in Get-AppScripts) {
        $script = Join-Path $Repo $app.Script
        if (-not (Test-Path $script)) { Write-Info "$($app.Name): no apply script yet, skipped"; continue }
        if (-not (& $app.Installed)) {
            $why = if ($app.ContainsKey('Missing')) { $app.Missing } else { 'not installed' }
            Write-Info "$($app.Name): $why, skipped"; continue
        }
        # Get-Process sees every process, the caller's own parents included, so an app whose
        # terminal runs the bootstrap still counts as open
        if ($app.Process -and (Get-Process -Name $app.Process -ErrorAction SilentlyContinue)) {
            Write-Warn "$($app.Name): open, skipped. Quit it and run the bootstrap again to apply its settings"
            continue
        }
        if ($script:PlanMode) { Write-Info "Would apply $($app.Name)'s settings with $($app.Script)"; continue }
        if (-not $pwsh) { Write-Warn "$($app.Name): PowerShell 7 is not installed yet, skipped"; continue }
        # the theme is named so a script's own flag (Microchip Studio's -Close) is never read as the theme
        $arguments = @('-Theme', 'deep-dark') + $(if ($app.ContainsKey('Extra')) { @($app.Extra) } else { @() })
        $output = @(& $pwsh -NoProfile -File $script @arguments 2>&1 | ForEach-Object { "$_" })
        $last = ($output | Where-Object { $_.Trim() } | Select-Object -Last 1)
        if ($LASTEXITCODE -ne 0) { Write-Warn "$($app.Name): $last"; continue }
        if ($output.Count -and $output[0] -match 'skipped') { Write-Info "$($app.Name): not set up yet, skipped"; continue }
        Write-Ok "$($app.Name): $last"
    }
}
