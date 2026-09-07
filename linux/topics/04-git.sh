# =============================================================================
# Git aliases and helpers
# Identical to the mac profile so muscle memory carries across devices.
# =============================================================================

alias gs="git status"
alias ga="git add"
alias gaa="git add --all"
alias gcmt="git commit -m"
alias gpsh="git push"
alias gpul="git pull"
alias glog="git log --oneline --graph --decorate --all"
alias gco="git checkout"
alias gb="git branch"
alias gd="git diff"
alias gclean="git clean -fd"

# Stage everything, commit with a message then push in one step
gcp() {
    git add --all
    git commit -m "$1"
    git push
}

# Create and switch to a new branch in one step
gcb() { git checkout -b "$1"; }

# Undo the last commit but keep the changes staged
gundo() { git reset HEAD~1; }

# Delete a local branch - git will refuse if there are unmerged changes
gbd() { git branch -d "$1"; }

# Force-delete a local branch after a squash-merge - git won't see it as "merged", this is expected
gbdf() { git branch -D "$1"; }

# Switch to main and pull fast-forward only - the start-of-task ritual before branching
alias gmain="git checkout main && git pull --ff-only"

# Branch fresh off an up-to-date main in one step, the safest way to start real work
gnb() { git checkout main && git pull --ff-only && git checkout -b "$1"; }

# End-of-session cleanup: prune stale remote-tracking refs locally and on origin
alias gprune="git fetch --prune && git remote prune origin"

# Full end-of-task ritual: back on main with stale local and remote branches pruned
gdone() {
    git checkout main && git pull --ff-only
    [ -n "$1" ] && git branch -D "$1"
    git fetch --prune && git remote prune origin
}

# Enable squash auto-merge on the current branch's PR and delete the branch after it lands
automerge() { gh pr merge --squash --delete-branch --auto "$@"; }

# Pull latest in every repo under a directory (defaults to ~/dev/github/repos)
pull-all() {
    local repos_dir="${1:-$HOME/dev/github/repos}"
    local dir name output exit_code
    echo -e "${CYAN}Pulling all repos in $repos_dir...${RESET}"
    for dir in "$repos_dir"/*/; do
        if [[ -d "$dir/.git" ]]; then
            name=$(basename "$dir")
            printf "  %-42s" "$name"
            output=$(git -C "$dir" pull 2>&1)
            exit_code=$?
            if [[ $exit_code -ne 0 ]]; then
                echo -e "${RED}FAILED${RESET}"
            elif echo "$output" | grep -q "Already up to date"; then
                echo "up to date"
            else
                echo -e "${GREEN}updated${RESET}"
            fi
        fi
    done
    echo -e "${GREEN}Done.${RESET}"
}

# Show the current branch and clean/dirty state for every repo in a directory
repo-status() {
    local repos_dir="${1:-$HOME/dev/github/repos}"
    local dir name branch dirty
    echo "Repo status:"
    echo ""
    for dir in "$repos_dir"/*/; do
        if [[ -d "$dir/.git" ]]; then
            name=$(basename "$dir")
            branch=$(git -C "$dir" branch --show-current 2>/dev/null)
            dirty=$(git -C "$dir" status --short 2>/dev/null)
            if [[ -n "$dirty" ]]; then
                printf "  %-42s (%s) DIRTY\n" "$name" "$branch"
            else
                printf "  %-42s (%s) clean\n" "$name" "$branch"
            fi
        fi
    done
}
