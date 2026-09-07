# =============================================================================
# GitHub CLI shortcuts
# Requires: brew install gh  then  gh auth login
# I use these instead of opening a browser for routine PR and issue work.
# =============================================================================

# Pull requests
alias ghprl="gh pr list"                           # list open PRs
alias ghprv="gh pr view --web"                     # open current branch PR in browser
alias ghprc="gh pr create"                         # create a PR interactively
alias ghprs="gh pr status"                         # show PRs relevant to you
alias ghprm="gh pr merge --squash --delete-branch" # squash-merge and delete branch
alias ghprco="gh pr checkout"                      # check out a PR locally
alias ghprcomment="gh pr comment"
alias ghprclose="gh pr close"
alias ghprreopen="gh pr reopen"
alias ghprdiff="gh pr diff"
alias ghprready="gh pr ready"                      # mark a draft PR as ready for review
alias ghprupdate="gh pr update-branch"

# ghpr: create a PR from current branch with title and body
ghpr() {
    gh pr create --title "${1:?Usage: ghpr 'title' 'body'}" --body "${2:-}"
}

# Issues
alias ghissl="gh issue list"
alias ghissv="gh issue view"
alias ghissc="gh issue create"
alias ghissclose="gh issue close"
alias ghissreopen="gh issue reopen"
alias ghisspin="gh issue pin"
alias ghissunpin="gh issue unpin"
alias ghisscomment="gh issue comment"

# Workflows / CI
alias ghrun="gh run list"                          # list recent workflow runs
alias ghwatch="gh run watch"                       # watch a running workflow
alias ghfail="gh run list --status failure"        # list failed runs

# Repos
alias ghrls="gh release list"
alias ghrlsc="gh release create"
alias ghrepo="gh repo view --web"                  # open repo in browser
alias ghfork="gh repo fork"
alias ghclone="gh repo clone"

# Gists
alias ghgist="gh gist list"
alias ghgistc="gh gist create"

# auth
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

# GitHub Discussions has no native gh CLI command (confirmed: "unknown command discussion" as
# of this gh version), only reachable via gh api graphql. Not worth a thin wrapper alias for.
