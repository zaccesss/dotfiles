# =============================================================================
# Git aliases and helpers
# Same 'g' prefix as Mac and Linux so muscle memory carries across devices.
# =============================================================================

function gs    { git status }
function ga    { git add $args }
function gaa   { git add --all }
function gcmt  { git commit -m $args }
function gpsh  { git push $args }
function gpul  { git pull }
function glog  { git log --oneline --graph --decorate --all }
function gco   { git checkout $args }
function gb    { git branch $args }
function gd    { git diff }
function gclean { git clean -fd }

# Stage everything, commit with a message then push in one step
function gcp {
    param([string]$message)
    git add --all
    git commit -m $message
    git push
}

# Create and switch to a new branch in one step
function gcb {
    param([string]$branch)
    git checkout -b $branch
}

# Undo the last commit but keep the changes staged
function gundo { git reset HEAD~1 }

# Delete a local branch - git will refuse if there are unmerged changes
function gbd {
    param([string]$branch)
    git branch -d $branch
}

# Force-delete a local branch after a squash-merge - git won't see it as "merged", this is expected
function gbdf {
    param([string]$branch)
    git branch -D $branch
}

# Switch to main and pull fast-forward only - the start-of-task ritual before branching
function gmain { git checkout main; git pull --ff-only }

# Branch fresh off an up-to-date main in one step, the safest way to start real work
function gnb {
    param([string]$branch)
    git checkout main
    git pull --ff-only
    git checkout -b $branch
}

# End-of-session cleanup: prune stale remote-tracking refs locally and on origin
function gprune { git fetch --prune; git remote prune origin }

# Full end-of-task ritual: back on main with stale local and remote branches pruned
function gdone {
    param([string]$branch)
    git checkout main
    git pull --ff-only
    if ($branch) { git branch -D $branch }
    git fetch --prune
    git remote prune origin
}

# Enable squash auto-merge on the current branch's PR and delete the branch after it lands
function automerge { gh pr merge --squash --delete-branch --auto $args }

# Pull latest in every repo under C:\dev\github\repos
function pull-all {
    $reposDir = "C:\dev\github\repos"
    Write-Host "Pulling all repos in $reposDir..." -ForegroundColor Cyan
    Get-ChildItem -Path $reposDir -Directory | ForEach-Object {
        if (Test-Path "$($_.FullName)\.git") {
            $name = $_.Name
            Write-Host "  $($name.PadRight(42))" -NoNewline
            $result = git.exe -C $_.FullName pull 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Host "FAILED" -ForegroundColor Red
            } elseif ($result -match "Already up to date") {
                Write-Host "up to date" -ForegroundColor DarkGray
            } else {
                Write-Host "updated" -ForegroundColor Green
            }
        }
    }
    Write-Host "Done." -ForegroundColor Green
}

# Show clean/dirty status and current branch for every repo
function repo-status {
    $reposDir = "C:\dev\github\repos"
    Write-Host "Repo status:" -ForegroundColor Cyan
    Write-Host ""
    Get-ChildItem -Path $reposDir -Directory | ForEach-Object {
        if (Test-Path "$($_.FullName)\.git") {
            $name = $_.Name
            $branch = git.exe -C $_.FullName branch --show-current 2>$null
            $dirty = git.exe -C $_.FullName status --short 2>$null
            if ($dirty) {
                Write-Host "  $($name.PadRight(42)) ($branch) DIRTY" -ForegroundColor Yellow
            } else {
                Write-Host "  $($name.PadRight(42)) ($branch) clean" -ForegroundColor Green
            }
        }
    }
}
