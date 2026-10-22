# Git identity and hooks from the dotfiles' git folder. The gitconfig and SSH config hold a
# person's own name, email, keys and hosts, so they are copied once as a starting point and never
# overwritten; the hooks are linked so a change in the repository applies straight away

function Copy-StartingFile {
    param([string]$Source, [string]$Target)

    if (Test-Path $Target) {
        Write-Info "Keeping your existing $Target"
        return
    }
    if (-not $script:PlanMode -and -not (Test-Path $Source)) {
        Write-Warn "No starting file at $Source; skipping $Target"
        return
    }
    Invoke-Step "copy a starting $Target" {
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Target) | Out-Null
        Copy-Item $Source $Target
        Write-Warn "Edit $Target for your own name, email, keys and hosts"
    }
}

function Set-GitConfiguration {
    $gitconfigRepo = Join-Path $script:DotfilesDir 'git\gitconfig'
    $hooksRepo = Join-Path $script:DotfilesDir 'git\git-hooks'
    $sshRepo = Join-Path $script:DotfilesDir 'git\ssh'

    Get-Dotfiles

    Copy-StartingFile -Source (Join-Path $gitconfigRepo 'windows\gitconfig') -Target (Join-Path $HOME '.gitconfig')
    Copy-StartingFile -Source (Join-Path $sshRepo 'windows\config') -Target (Join-Path $HOME '.ssh\config')

    # a junction needs no administrator rights, unlike a symbolic link
    $hooksLink = Join-Path $HOME '.git-hooks'
    $hooksTarget = Join-Path $hooksRepo 'windows'
    if (Test-LegacyCloneLink (Get-Item -Force $hooksLink -ErrorAction SilentlyContinue)) {
        Invoke-Step "remove the earlier $hooksLink link into the old git-hooks clone" { Remove-FolderLink $hooksLink }
    }
    if ((Test-Path $hooksLink) -and ((Get-Item -Force $hooksLink).Target -contains $hooksTarget)) {
        Write-Info 'Git hooks already point at the repository'
    } elseif (Test-Path $hooksLink) {
        Write-Warn "$hooksLink exists and is not the repository's hooks; leaving it for you to check"
    } else {
        Invoke-Step "link $hooksLink to $hooksTarget" {
            New-Item -ItemType Junction -Path $hooksLink -Target $hooksTarget | Out-Null
        }
    }

    # keys are never stored in a repository, so a new PC makes its own and adds them to GitHub
    if (-not (Test-Path (Join-Path $HOME '.ssh\git_sign_ed25519'))) {
        Write-Warn 'No signing key yet. Create one with: ssh-keygen -t ed25519 -f ~/.ssh/git_sign_ed25519 -C "<this PC>"'
        Write-Warn 'Then add it to GitHub as a signing key: gh ssh-key add ~/.ssh/git_sign_ed25519.pub --type signing'
    }
}
