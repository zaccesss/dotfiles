# =============================================================================
# GitHub CLI shortcuts - Windows PowerShell
# Requires: winget install GitHub.cli  then  gh auth login
# =============================================================================

function ghprl     { gh pr list }
function ghprv     { gh pr view --web }
function ghprc     { gh pr create }
function ghprs     { gh pr status }
function ghprm     { gh pr merge --squash --delete-branch }
function ghprco    { param($Num) gh pr checkout $Num }
function ghprcomment { param($Num, $Body) gh pr comment $Num --body $Body }
function ghprclose { param($Num) gh pr close $Num }
function ghprreopen { param($Num) gh pr reopen $Num }
function ghprdiff  { param($Num) gh pr diff $Num }
function ghprready { param($Num) gh pr ready $Num }
function ghprupdate { param($Num) gh pr update-branch $Num }

function ghpr {
    param([string]$Title, [string]$Body = "")
    gh pr create --title $Title --body $Body
}

function ghissl    { gh issue list }
function ghissv    { param($Num) gh issue view $Num }
function ghissc    { gh issue create }
function ghissclose { param($Num) gh issue close $Num }
function ghissreopen { param($Num) gh issue reopen $Num }
function ghisspin  { param($Num) gh issue pin $Num }
function ghissunpin { param($Num) gh issue unpin $Num }
function ghisscomment { param($Num, $Body) gh issue comment $Num --body $Body }

function ghrun     { gh run list }
function ghwatch   { param($RunId) gh run watch $RunId }
function ghfail    { gh run list --status failure }

function ghrls     { gh release list }
function ghrlsc    { gh release create @args }
function ghrepo    { gh repo view --web }
function ghfork    { gh repo fork @args }
function ghclone   { param($Repo) gh repo clone $Repo }

function ghgist    { gh gist list }
function ghgistc   { gh gist create @args }
function ghwho     { gh auth status }

# Labels: list, add to a PR/issue
function ghlabels { gh label list }
function ghaddlabel {
    param($Num, $Label)
    gh pr edit $Num --add-label $Label 2>$null
    if ($LASTEXITCODE -ne 0) { gh issue edit $Num --add-label $Label }
}

# Review with a comment - use on your own repos, where self-approval is blocked anyway
function ghreview {
    param($Num, $Body)
    gh pr review $Num --comment --body $Body
}

# Approve - only for someone else's repo or a fork, never your own
function ghapprove {
    param($Num, [string]$Body = "")
    gh pr review $Num --approve --body $Body
}

function ghprchecks { param($Num) gh pr checks $Num }

# Branch protection / ruleset check for the current repo
function ghrules { gh api repos/{owner}/{repo}/rulesets --jq '.[].name' }

# Issues/PRs assigned to you in the current repo
function ghmine    { gh issue list --assignee @me }
function ghprmine  { gh pr list --assignee @me }

# Full create-issue-with-label-then-branch ritual, matching the real issue -> branch -> PR flow
function ghstart {
    param([string]$Title, [string]$Label, [string]$Branch)
    gh issue create --title $Title --label $Label
    git checkout main
    git pull --ff-only
    git checkout -b $Branch
}

# Projects (v2)
function ghprojls   { gh project list }
function ghprojview { param($Num) gh project view $Num }
function ghprojadd  { param($Num, $Url) gh project item-add $Num --url $Url }

# Clone a repo's wiki - GitHub CLI has no native wiki command, it's a real git repo of its own
function ghwiki {
    param([string]$Repo)
    git clone "https://github.com/$Repo.wiki.git"
}

# Sync a fork with its upstream
function ghsync { gh repo sync @args }
