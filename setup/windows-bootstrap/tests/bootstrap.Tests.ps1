# Pester tests for the parts of the bootstrap that can be checked without changing a PC: the
# package list, the extension list parsing, the pointer files and plan mode end to end.

BeforeAll {
    $script:Root = Split-Path -Parent $PSScriptRoot
    $lib = Join-Path $script:Root 'bootstrap\lib'
    . (Join-Path $lib 'common.ps1')
    . (Join-Path $lib 'winget.ps1')
    . (Join-Path $lib 'vscode.ps1')
    $script:PlanMode = $false
}

Describe 'package list' {
    It 'is valid winget import JSON with unique publisher.name identifiers' {
        $ids = Get-PackageIds
        $ids.Count | Should -BeGreaterThan 30
        ($ids | Sort-Object -Unique).Count | Should -Be $ids.Count
        $ids | ForEach-Object { $_ | Should -Match '^[A-Za-z0-9-]+\.[A-Za-z0-9.+-]+$' }
    }

    It 'covers the everyday tools the shell profile expects' {
        $ids = Get-PackageIds
        foreach ($id in 'Git.Git', 'GitHub.cli', 'Microsoft.PowerShell', 'Starship.Starship', 'ajeetdsouza.zoxide', 'BurntSushi.ripgrep.MSVC', 'Microsoft.VisualStudioCode') {
            $ids | Should -Contain $id
        }
    }

    It 'installs Python through the Install Manager rather than a versioned package' {
        $ids = Get-PackageIds
        $ids | Should -Contain 'Python.PythonInstallManager'
        $ids | Where-Object { $_ -match '^Python\.Python\.3' } | Should -BeNullOrEmpty
    }
}

Describe 'Install-PythonRuntime' {
    It 'installs nothing and changes no setting in plan mode' {
        Mock Test-Command { $false }
        Mock Invoke-Step { }
        $script:PlanMode = $true
        try { Install-PythonRuntime 3>$null 6>$null } finally { $script:PlanMode = $false }
        Should -Invoke Invoke-Step -ParameterFilter { $Description -like 'install Python*' } -Times 1
    }

    It 'skips the download when the version is already installed' {
        Mock Test-Command { $true }
        function pymanager { 'C:\Python\python.exe' }
        Mock Invoke-Step { }
        Install-PythonRuntime 3>$null 6>$null
        Should -Invoke Invoke-Step -ParameterFilter { $Description -like 'install Python*' } -Times 0
    }
}

Describe 'Get-WantedExtensions' {
    It 'strips pinned versions, comments and blank lines and lowercases names' {
        $list = Join-Path $TestDrive 'extensions.txt'
        Set-Content $list @('// editors', 'EditorConfig.EditorConfig@0.16.4', '', '# notes', 'eamodio.gitlens')
        Get-WantedExtensions -ListPath $list | Should -Be @('editorconfig.editorconfig', 'eamodio.gitlens')
    }
}

Describe 'Set-PointerFile' {
    It 'writes the pointer when no file exists' {
        $path = Join-Path $TestDrive 'new\profile.ps1'
        Set-PointerFile -Path $path -Content '. "C:\dotfiles\profile.ps1"'
        Get-Content -Raw $path | Should -Match 'dotfiles'
    }

    It 'sends a different existing file to the Recycle Bin and keeps no copy' {
        Mock Move-ToRecycleBin { Remove-Item -LiteralPath $Path }
        $path = Join-Path $TestDrive 'existing\profile.ps1'
        New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
        Set-Content $path '# my own profile'
        Set-PointerFile -Path $path -Content '. "C:\dotfiles\profile.ps1"' 6>$null
        Should -Invoke Move-ToRecycleBin -Times 1
        Get-Content -Raw $path | Should -Match 'dotfiles'
        (Get-ChildItem (Split-Path $path)).Name | Should -Be 'profile.ps1'
    }

    It 'leaves a file that already points at the dotfiles untouched' {
        $path = Join-Path $TestDrive 'same\profile.ps1'
        New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
        Set-Content $path '. "C:\dotfiles\profile.ps1"'
        Set-PointerFile -Path $path -Content '. "C:\dotfiles\profile.ps1"'
        (Get-ChildItem (Split-Path $path)).Count | Should -Be 1
    }
}

Describe 'Resolve-SkipList' {
    It 'accepts an array and a single comma-separated string alike' {
        Resolve-SkipList -Skip @('winget', 'settings') | Should -Be @('winget', 'settings')
        Resolve-SkipList -Skip 'winget, settings' | Should -Be @('winget', 'settings')
    }

    It 'stops on an unknown stage' {
        { Resolve-SkipList -Skip 'winget,nope' } | Should -Throw '*nope*'
    }
}

Describe 'New-FilteredPackageFile' {
    It 'leaves out the given packages and keeps the rest' {
        $path = New-FilteredPackageFile -Exclude @('Adobe.Acrobat.Reader.64-bit') -Path (Join-Path $TestDrive 'winget.json')
        $ids = @((Get-Content -Raw $path | ConvertFrom-Json).Sources.Packages.PackageIdentifier)
        $ids | Should -Not -Contain 'Adobe.Acrobat.Reader.64-bit'
        $ids.Count | Should -Be ((Get-PackageIds).Count - 1)
    }
}

Describe 'Get-MachineSkipList' {
    It 'reads the ids and drops comments and blank lines' {
        $dir = Join-Path $TestDrive 'skip'
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Set-Content (Join-Path $dir 'TEST-PC.txt') @('# apps this PC leaves out', 'KiCad.KiCad', '', 'Figma.Figma  # not here')
        Get-MachineSkipList -ComputerName 'TEST-PC' -SkipDir $dir | Should -Be @('KiCad.KiCad', 'Figma.Figma')
    }

    It 'returns nothing for a PC with no list' {
        Get-MachineSkipList -ComputerName 'NO-SUCH-PC' -SkipDir (Join-Path $TestDrive 'skip') | Should -BeNullOrEmpty
    }

    It 'only names packages that are in the package list' {
        $ids = Get-PackageIds
        Get-ChildItem (Join-Path $script:Root 'packages\skip') -Filter '*.txt' -ErrorAction SilentlyContinue | ForEach-Object {
            Get-MachineSkipList -ComputerName $_.BaseName | ForEach-Object { $ids | Should -Contain $_ }
        }
    }
}

Describe 'Hide-HomeDotItems' {
    BeforeAll {
        . (Join-Path $script:Root 'bootstrap\lib\configs.ps1')
    }

    It 'hides dot folders and files only; plan mode changes nothing' {
        $homePath = Join-Path $TestDrive 'dothome'
        New-Item -ItemType Directory -Force -Path (Join-Path $homePath '.config'), (Join-Path $homePath 'dev') | Out-Null
        Set-Content -Path (Join-Path $homePath '.gitconfig') -Value 'x'
        Set-Content -Path (Join-Path $homePath 'notes.txt') -Value 'x'
        $isHidden = { param($Name) [bool]((Get-Item -LiteralPath (Join-Path $homePath $Name) -Force).Attributes -band [IO.FileAttributes]::Hidden) }

        $script:PlanMode = $true
        try { Hide-HomeDotItems -HomePath $homePath 6>$null } finally { $script:PlanMode = $false }
        & $isHidden '.config' | Should -BeFalse

        Hide-HomeDotItems -HomePath $homePath 6>$null
        & $isHidden '.config' | Should -BeTrue
        & $isHidden '.gitconfig' | Should -BeTrue
        & $isHidden 'dev' | Should -BeFalse
        & $isHidden 'notes.txt' | Should -BeFalse
    }
}

Describe 'Windows Terminal schemes' {
    BeforeAll {
        . (Join-Path $script:Root 'bootstrap\lib\common.ps1')
        . (Join-Path $script:Root 'bootstrap\lib\configs.ps1')
        $script:PlanMode = $false
    }

    It 'sets Zacess Deep Contrast Dark and bold text, keeping comments out of the way' {
        $path = Join-Path $TestDrive 'settings.json'
        Set-Content $path "// generated by Windows Terminal`n{ ""profiles"": { ""defaults"": {}, ""list"": [] } }"
        Set-TerminalScheme -SettingsPath $path 6>$null
        $saved = Get-Content -Raw $path | ConvertFrom-Json
        $saved.profiles.defaults.colorScheme | Should -Be 'Zacess Deep Contrast Dark'
        $saved.profiles.defaults.intenseTextStyle | Should -Be 'bold'
        $saved.theme | Should -Be 'system'
        $saved.profiles.defaults.font.face | Should -Be 'GeistMono NFM'
    }

    It 'skips the Geist Mono download when the font is installed; plan mode changes nothing' {
        $fonts = Join-Path $TestDrive 'fonts'
        $script:PlanMode = $true
        try { Install-GeistMonoFont -FontDir $fonts -RegistryKey 'TestRegistry:\Fonts' 6>$null } finally { $script:PlanMode = $false }
        $fonts | Should -Not -Exist
        New-Item -ItemType Directory -Force -Path $fonts | Out-Null
        Set-Content (Join-Path $fonts 'GeistMonoNerdFont-Regular.otf') 'x'
        Set-Content (Join-Path $fonts 'GeistMonoNerdFontMono-Regular.otf') 'x'
        Mock Invoke-WebRequest { throw 'no download expected' }
        Install-GeistMonoFont -FontDir $fonts -RegistryKey 'TestRegistry:\Fonts' 6>$null
        Should -Invoke Invoke-WebRequest -Times 0
    }

    It 'downloads Geist Mono again when only the first build is installed' {
        $fonts = Join-Path $TestDrive 'fonts-first-build'
        New-Item -ItemType Directory -Force -Path $fonts | Out-Null
        Set-Content (Join-Path $fonts 'GeistMonoNerdFont-Regular.otf') 'x'
        Mock Invoke-WebRequest { throw 'download started' }
        { Install-GeistMonoFont -FontDir $fonts -RegistryKey 'TestRegistry:\Fonts' 6>$null } | Should -Throw 'download started'
    }

    It 'installs Geist Mono for all users from the per-user copy; plan mode changes nothing' {
        $source = Join-Path $TestDrive 'user-fonts'
        $machine = Join-Path $TestDrive 'machine-fonts'
        New-Item -ItemType Directory -Force -Path $source, $machine | Out-Null
        foreach ($name in 'GeistMonoNerdFont-Regular.otf', 'GeistMonoNerdFontMono-Regular.otf', 'GeistMonoNerdFontPropo-Regular.otf') {
            Set-Content (Join-Path $source $name) 'x'
        }
        $script:PlanMode = $true
        try { Install-GeistMonoFontAllUsers -SourceDir $source -FontDir $machine -RegistryKey 'TestRegistry:\MachineFonts' -NoElevation 6>$null } finally { $script:PlanMode = $false }
        (Get-ChildItem $machine).Count | Should -Be 0
        Install-GeistMonoFontAllUsers -SourceDir $source -FontDir $machine -RegistryKey 'TestRegistry:\MachineFonts' -NoElevation 6>$null
        (Get-ChildItem $machine).Name | Should -Be @('GeistMonoNerdFont-Regular.otf', 'GeistMonoNerdFontMono-Regular.otf')
        (Get-ItemProperty 'TestRegistry:\MachineFonts').'GeistMonoNerdFontMono-Regular (OpenType)' | Should -Be 'GeistMonoNerdFontMono-Regular.otf'
    }

    It 'skips the all-users install when both builds are already there' {
        $machine = Join-Path $TestDrive 'machine-fonts-done'
        New-Item -ItemType Directory -Force -Path $machine | Out-Null
        Set-Content (Join-Path $machine 'GeistMonoNerdFont-Regular.otf') 'x'
        Set-Content (Join-Path $machine 'GeistMonoNerdFontMono-Regular.otf') 'x'
        Mock Copy-Item { throw 'no copy expected' }
        Install-GeistMonoFontAllUsers -SourceDir $machine -FontDir $machine -RegistryKey 'TestRegistry:\MachineFonts2' -NoElevation 6>$null
        Should -Invoke Copy-Item -Times 0
    }

    It 'replaces the earlier High Contrast pair but keeps a Zacess choice' {
        $path = Join-Path $TestDrive 'pair.json'
        Set-Content $path '{ "theme": "system", "profiles": { "defaults": { "colorScheme": { "dark": "High Contrast Dark", "light": "High Contrast Light" } } } }'
        Set-TerminalScheme -SettingsPath $path 6>$null
        (Get-Content -Raw $path | ConvertFrom-Json).profiles.defaults.colorScheme | Should -Be 'Zacess Deep Contrast Dark'
        Set-Content $path '{ "theme": "system", "profiles": { "defaults": { "colorScheme": "Zacess Cream" } } }'
        Set-TerminalScheme -SettingsPath $path 6>$null
        (Get-Content -Raw $path | ConvertFrom-Json).profiles.defaults.colorScheme | Should -Be 'Zacess Cream'
    }

    It 'leaves a file that already uses a Zacess scheme and Geist Mono untouched' {
        $path = Join-Path $TestDrive 'done.json'
        Set-Content $path '{ "theme": "system", "profiles": { "defaults": { "colorScheme": "Zacess Deep Contrast Dark", "intenseTextStyle": "bold", "font": { "face": "GeistMono NFM" } } } }'
        $written = Get-Content -Raw $path
        Set-TerminalScheme -SettingsPath $path 6>$null
        Get-Content -Raw $path | Should -Be $written
        (Get-ChildItem $TestDrive -Filter 'done.json*').Name | Should -Be 'done.json'
    }
}

Describe 'Install-AppSettings' {
    BeforeAll {
        . (Join-Path $script:Root 'bootstrap\lib\common.ps1')
        . (Join-Path $script:Root 'bootstrap\lib\apps.ps1')
        # the bootstrap runs in strict mode, so the stage is tested the same way
        Set-StrictMode -Version Latest
        $script:AppRepo = Join-Path $TestDrive 'app-repo'
        $script:AppScript = Join-Path $script:AppRepo 'editors\demo\windows\apply.ps1'
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $script:AppScript) | Out-Null
        Set-Content -LiteralPath $script:AppScript "Write-Output '  changed  demo'; Write-Output 'Theme: Zacess Deep Contrast Dark'"
        $script:OwnProcess = (Get-Process -Id $PID).ProcessName
    }

    It 'runs an installed, closed app''s script and prints its last line' {
        Mock Get-AppScripts { @(@{ Name = 'Demo'; Script = 'editors\demo\windows\apply.ps1'; Process = 'no-such-process-zacess'; Installed = { $true } }) }
        $script:PlanMode = $false
        $output = Install-AppSettings -Repo $script:AppRepo 6>&1 | Out-String
        $output | Should -Match 'Demo: Theme: Zacess Deep Contrast Dark'
    }

    It 'skips an app that is open, even when it is this process''s own parent' {
        Mock Get-AppScripts { @(@{ Name = 'Demo'; Script = 'editors\demo\windows\apply.ps1'; Process = $script:OwnProcess; Installed = { $true } }) }
        $script:PlanMode = $false
        $output = Install-AppSettings -Repo $script:AppRepo 6>&1 | Out-String
        $output | Should -Match 'Demo: open, skipped'
        $output | Should -Not -Match 'Theme:'
    }

    It 'skips an app that is not installed' {
        Mock Get-AppScripts { @(@{ Name = 'Demo'; Script = 'editors\demo\windows\apply.ps1'; Process = $null; Installed = { $false } }) }
        $output = Install-AppSettings -Repo $script:AppRepo 6>&1 | Out-String
        $output | Should -Match 'Demo: not installed, skipped'
    }

    It 'gives every app in the real list a working installed check under strict mode' {
        foreach ($app in Get-AppScripts) {
            { & $app.Installed } | Should -Not -Throw -Because "$($app.Name)'s check must still see its folder paths"
            $app.ContainsKey('Extra') | Should -BeTrue
        }
    }

    It 'only reports what it would run in plan mode' {
        Mock Get-AppScripts { @(@{ Name = 'Demo'; Script = 'editors\demo\windows\apply.ps1'; Process = 'no-such-process-zacess'; Installed = { $true } }) }
        $script:PlanMode = $true
        $output = Install-AppSettings -Repo $script:AppRepo 6>&1 | Out-String
        $script:PlanMode = $false
        $output | Should -Match "Would apply Demo's settings"
        $output | Should -Not -Match 'Theme:'
    }
}

Describe 'plan mode' {
    It 'runs every stage and changes nothing' {
        $env:WINDOWS_BOOTSTRAP_ALLOW_ANY_OS = '1'
        $env:WINDOWS_BOOTSTRAP_REPOS_DIR = Join-Path $TestDrive 'repos'
        $output = & (Join-Path $script:Root 'bootstrap\bootstrap.ps1') -Plan -Skip vscode 6>&1 | Out-String
        foreach ($stage in 'winget', 'dotfiles', 'git', 'configs', 'settings', 'wsl', 'apps') {
            $output | Should -Match "Completed stage: $stage"
        }
        $output | Should -Match 'Would clone dotfiles into'
        Test-Path $env:WINDOWS_BOOTSTRAP_REPOS_DIR | Should -BeFalse
    }

    It 'skips stages given as one comma-separated string' {
        $env:WINDOWS_BOOTSTRAP_ALLOW_ANY_OS = '1'
        $env:WINDOWS_BOOTSTRAP_REPOS_DIR = Join-Path $TestDrive 'repos'
        $output = & (Join-Path $script:Root 'bootstrap\bootstrap.ps1') -Plan -Skip 'vscode,settings' 6>&1 | Out-String
        $output | Should -Match 'Skipping stage: vscode'
        $output | Should -Match 'Skipping stage: settings'
        $output | Should -Not -Match 'Completed stage: settings'
    }
}

Describe 'Command Prompt start-up' {
    BeforeAll {
        . (Join-Path $script:Root 'bootstrap\lib\common.ps1')
        . (Join-Path $script:Root 'bootstrap\lib\dotfiles.ps1')
    }

    It 'sets the start-up when there is no AutoRun yet' {
        Get-CmdAutoRunValue -Existing '' -Script 'C:\r\autorun.cmd' | Should -Be 'call "C:\r\autorun.cmd"'
    }

    It 'chains an earlier AutoRun after it rather than replacing it' {
        Get-CmdAutoRunValue -Existing 'C:\tools\init.cmd' -Script 'C:\r\autorun.cmd' |
            Should -Be 'call "C:\r\autorun.cmd" & C:\tools\init.cmd'
    }

    It 'leaves a value that already runs it alone' {
        $value = 'call "C:\r\autorun.cmd" & C:\tools\init.cmd'
        Get-CmdAutoRunValue -Existing $value -Script 'C:\r\autorun.cmd' | Should -Be $value
    }
}

Describe 'Update-LegacyProfilePointer' {
    BeforeAll {
        . (Join-Path $script:Root 'bootstrap\lib\dotfiles.ps1')
        # a replaced file only has to be gone; the runner's own Recycle Bin is left alone
        Mock Move-ToRecycleBin { Remove-Item -LiteralPath $Path -Force }
    }

    It 'moves a pointer at the old loader and leaves any other profile alone' {
        $old = 'C:\r\dotfiles\windows\Microsoft.PowerShell_profile.ps1'
        $new = 'C:\r\dotfiles\shell\windows\Microsoft.PowerShell_profile.ps1'
        $pointer = Join-Path $TestDrive 'ps5-pointer.ps1'
        Set-Content $pointer ". `"$old`""
        Update-LegacyProfilePointer -Path $pointer -OldLoader $old -NewLoader $new 6>$null 3>$null
        (Get-Content -Raw $pointer).Trim() | Should -Be ". `"$new`""
        $own = Join-Path $TestDrive 'ps5-own.ps1'
        Set-Content $own 'Set-Alias ll Get-ChildItem'
        Update-LegacyProfilePointer -Path $own -OldLoader $old -NewLoader $new
        (Get-Content -Raw $own).Trim() | Should -Be 'Set-Alias ll Get-ChildItem'
        Update-LegacyProfilePointer -Path (Join-Path $TestDrive 'missing.ps1') -OldLoader $old -NewLoader $new
        Join-Path $TestDrive 'missing.ps1' | Should -Not -Exist
    }
}

Describe 'links from before the move' {
    It 'clones into dev\github\repos by default' {
        $saved = $env:BOOTSTRAP_CONFIG_DIR, $env:WINDOWS_BOOTSTRAP_REPOS_DIR
        try {
            $env:BOOTSTRAP_CONFIG_DIR = $null
            $env:WINDOWS_BOOTSTRAP_REPOS_DIR = $null
            . (Join-Path $script:Root 'bootstrap\lib\common.ps1')
            $script:DotfilesDir | Should -Be (Join-Path $HOME 'dev\github\repos\dotfiles')
        } finally {
            $env:BOOTSTRAP_CONFIG_DIR, $env:WINDOWS_BOOTSTRAP_REPOS_DIR = $saved
            . (Join-Path $script:Root 'bootstrap\lib\common.ps1')
        }
    }

    It 'recognises a junction into an old clone but not one into the current clone' {
        $old = [pscustomobject]@{ LinkType = 'Junction'; Target = @(Join-Path $script:LegacyReposDir 'neovim-config\windows\nvim') }
        $new = [pscustomobject]@{ LinkType = 'Junction'; Target = @(Join-Path $script:DotfilesDir 'editors\neovim\windows\nvim') }
        $folder = [pscustomobject]@{ LinkType = $null; Target = $null }
        Test-LegacyCloneLink $old | Should -BeTrue
        Test-LegacyCloneLink $new | Should -BeFalse
        Test-LegacyCloneLink $folder | Should -BeFalse
        Test-LegacyCloneLink $null | Should -BeFalse
    }

    It 'leaves links into folders that were never one of the old clones' {
        foreach ($repo in 'notes', 'my-config', 'neovim-config-extra') {
            $link = [pscustomobject]@{ LinkType = 'Junction'; Target = @(Join-Path $script:LegacyReposDir "$repo\windows") }
            Test-LegacyCloneLink $link | Should -BeFalse -Because "$repo was never cloned by an earlier release"
        }
        $exact = [pscustomobject]@{ LinkType = 'SymbolicLink'; Target = @(Join-Path $script:LegacyReposDir 'cli-tools-config') }
        Test-LegacyCloneLink $exact | Should -BeTrue
    }

    It 'drops the Command Prompt start-up''s earlier paths and keeps another tool''s AutoRun' {
        . (Join-Path $script:Root 'bootstrap\lib\dotfiles.ps1')
        $old = 'C:\h\.dotfiles\dotfiles\windows\cmd\autorun.cmd'
        $new = 'C:\h\dev\github\repos\dotfiles\shell\windows\cmd\autorun.cmd'
        Get-CmdAutoRunValue -Existing "call `"$old`"" -Script $new -Replaces $old | Should -Be "call `"$new`""
        Get-CmdAutoRunValue -Existing "call `"$old`" & C:\tools\init.cmd" -Script $new -Replaces $old |
            Should -Be "call `"$new`" & C:\tools\init.cmd"
        Get-CmdAutoRunValue -Existing "C:\tools\init.cmd & call `"$old`"" -Script $new -Replaces $old |
            Should -Be "call `"$new`" & C:\tools\init.cmd"
    }

    It 'lists the old shell folders but never the current one' {
        . (Join-Path $script:Root 'bootstrap\lib\dotfiles.ps1')
        $folders = @(Get-LegacyShellFolders)
        $folders | Should -Contain (Join-Path $script:LegacyReposDir 'dotfiles')
        $folders | Should -Not -Contain (Join-Path $script:DotfilesDir 'shell')
    }
}
