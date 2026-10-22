# Pester tests for windows/defaults.ps1. The file checks run anywhere; the registry round trip runs
# only on Windows, using a throwaway key under HKCU so no real setting is touched.

BeforeAll {
    $script:Root = Split-Path -Parent $PSScriptRoot
    $script:Script = [IO.Path]::Combine($script:Root, 'windows', 'defaults.ps1')
    $script:OnWindows = if ($null -ne (Get-Variable -Name IsWindows -ErrorAction SilentlyContinue)) { $IsWindows } else { $true }
}

Describe 'tracked list' {
    It 'names only HKEY_CURRENT_USER values, each as a key path then a value name' {
        $lines = Get-Content ([IO.Path]::Combine($script:Root, 'windows', 'tracked.txt')) | Where-Object { $_ -and $_ -notmatch '^\s*#' }
        $lines.Count | Should -BeGreaterThan 20
        $lines | ForEach-Object { $_ | Should -Match '^HKCU:\\\S.* \S+$' }
    }

    It 'starts the values file with a header row' {
        (Get-Content ([IO.Path]::Combine($script:Root, 'windows', 'defaults.tsv')) -TotalCount 1) | Should -Be "path`tname`ttype`tvalue"
    }
}

Describe 'registry round trip' -Skip:(-not $script:OnWindows) {
    BeforeAll {
        $script:Key = 'HKCU:\Software\SystemDefaultsTest'
        New-Item -Path $script:Key -Force | Out-Null
        New-ItemProperty -Path $script:Key -Name Number -Value 7 -PropertyType DWord -Force | Out-Null
        New-ItemProperty -Path $script:Key -Name Folder -Value "$HOME\Pictures\Shots" -PropertyType String -Force | Out-Null
        New-ItemProperty -Path $script:Key -Name Expanded -Value "$HOME\Pictures\Screenshots" -PropertyType ExpandString -Force | Out-Null
        $script:Tracked = Join-Path $TestDrive 'tracked.txt'
        $script:Values = Join-Path $TestDrive 'defaults.tsv'
        Set-Content $script:Tracked @("$script:Key Number", "$script:Key Folder", "$script:Key Expanded", "$script:Key Missing")
    }

    AfterAll { Remove-Item -Path $script:Key -Recurse -Force -ErrorAction SilentlyContinue }

    It 'captures only values that are set, with home paths made portable' {
        & $script:Script -Capture -TrackedFile $script:Tracked -ValuesFile $script:Values | Out-Null
        $rows = Import-Csv $script:Values -Delimiter "`t"
        $rows.Count | Should -Be 3
        ($rows | Where-Object name -eq 'Folder').value | Should -Be '%USERPROFILE%\Pictures\Shots'
    }

    It 'restores a changed value and leaves matching ones alone' {
        Set-ItemProperty -Path $script:Key -Name Number -Value 1
        $output = & $script:Script -TrackedFile $script:Tracked -ValuesFile $script:Values 6>&1 | Out-String
        (Get-ItemProperty -Path $script:Key).Number | Should -Be 7
        $output | Should -Not -Match 'Set .* Folder'
    }

    It 'treats an expandable home path as matching in either form' {
        $output = & $script:Script -Plan -TrackedFile $script:Tracked -ValuesFile $script:Values 6>&1 | Out-String
        $output | Should -Not -Match 'Would set .* Expanded'
    }

    It 'changes nothing in plan mode' {
        Set-ItemProperty -Path $script:Key -Name Number -Value 2
        & $script:Script -Plan -TrackedFile $script:Tracked -ValuesFile $script:Values | Out-Null
        (Get-ItemProperty -Path $script:Key).Number | Should -Be 2
    }
}
