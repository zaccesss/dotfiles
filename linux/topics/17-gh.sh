# =============================================================================
# GitHub CLI shortcuts - same as mac but .sh extension for bash
# Requires: gh auth login
# =============================================================================

alias ghprl="gh pr list"
alias ghprv="gh pr view --web"
alias ghprc="gh pr create"
alias ghprs="gh pr status"
alias ghprm="gh pr merge --squash --delete-branch"
alias ghprco="gh pr checkout"
alias ghprcomment="gh pr comment"
alias ghprclose="gh pr close"
alias ghprreopen="gh pr reopen"
alias ghprdiff="gh pr diff"
alias ghprready="gh pr ready"
alias ghprupdate="gh pr update-branch"

ghpr() {
    gh pr create --title "${1:?Usage: ghpr 'title' 'body'}" --body "${2:-}"
}

alias ghissl="gh issue list"
alias ghissv="gh issue view"
alias ghissc="gh issue create"
alias ghissclose="gh issue close"
alias ghissreopen="gh issue reopen"
alias ghisspin="gh issue pin"
alias ghissunpin="gh issue unpin"
alias ghisscomment="gh issue comment"

alias ghrun="gh run list"
alias ghwatch="gh run watch"
alias ghfail="gh run list --status failure"

alias ghrls="gh release list"
alias ghrlsc="gh release create"
alias ghrepo="gh repo view --web"
alias ghfork="gh repo fork"
alias ghclone="gh repo clone"

alias ghgist="gh gist list"
alias ghgistc="gh gist create"
alias ghwho="gh auth status"

# Labels: list, add to a PR/issue
alias ghlabels="gh label list"
ghaddlabel() {
    gh pr edit "$1" --add-label "$2" 2>/dev/null || gh issue edit "$1" --add-label "$2"
}

# Review with a comment - use on your own repos, where self-approval is blocked anyway
ghreview() {
    gh pr review "$1" --comment --body "$2"
}

# Approve - only for someone else's repo or a fork, never your own
ghapprove() {
    gh pr review "$1" --approve --body "${2:-}"
}

alias ghprchecks="gh pr checks"

# Branch protection / ruleset check for the current repo
alias ghrules="gh api repos/{owner}/{repo}/rulesets --jq '.[].name'"

# Issues/PRs assigned to you in the current repo
alias ghmine="gh issue list --assignee @me"
alias ghprmine="gh pr list --assignee @me"

# Full create-issue-with-label-then-branch ritual, matching the real issue -> branch -> PR flow
ghstart() {
    local title="$1" label="$2" branch="$3"
    gh issue create --title "$title" --label "$label"
    git checkout main && git pull --ff-only && git checkout -b "$branch"
}

# Projects (v2)
alias ghprojls="gh project list"
alias ghprojview="gh project view"
alias ghprojadd="gh project item-add"

# Clone a repo's wiki - GitHub CLI has no native wiki command, it's a real git repo of its own
ghwiki() {
    git clone "https://github.com/${1:?Usage: ghwiki owner/repo}.wiki.git"
}

# Sync a fork with its upstream
alias ghsync="gh repo sync"
