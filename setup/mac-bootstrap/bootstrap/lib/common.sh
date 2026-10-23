#!/usr/bin/env bash
#
# shared plumbing for every stage. Written for the bash 3.2 that ships with macOS, because a new
# Mac has no other bash until Homebrew installs one: no associative arrays, no mapfile and no
# ${var,,} case changes anywhere in this repository.
#
# run modes:
#   normal   changes the Mac for real
#   test     MAC_BOOTSTRAP_TEST_MODE=1. brew, defaults, gh, git and the other commands are stubs
#            from the test suite, so nothing touches the network or the machine

readonly BOOTSTRAP_STATE_DIR="${HOME}/.local/state/mac-bootstrap"
# the dotfiles repository, which holds the shell profile and every tool config in its own folder,
# is cloned here. It defaults to the public one this project lives in; point BOOTSTRAP_GITHUB_USER
# at your own account to use your fork
readonly REPOS_DIR="${BOOTSTRAP_CONFIG_DIR:-${MAC_BOOTSTRAP_REPOS_DIR:-${HOME}/dev/github/repos}}"
readonly GITHUB_USER="${BOOTSTRAP_GITHUB_USER:-zaccesss}"
readonly DOTFILES_DIR="${REPOS_DIR}/dotfiles"

is_test_mode() {
    [[ "${MAC_BOOTSTRAP_TEST_MODE:-0}" == "1" ]]
}

initialise_bootstrap() {
    mkdir -p "$BOOTSTRAP_STATE_DIR"
    log_info "Bootstrap state directory: $BOOTSTRAP_STATE_DIR"
}

# asks for the administrator password, once, the first time a step really needs it, then keeps
# the timestamp fresh so a long install never stops at a second prompt. A re-run on a Mac that is
# already set up never asks at all
SUDO_READY=0
require_sudo() {
    if (( SUDO_READY )); then
        return 0
    fi
    SUDO_READY=1

    if is_test_mode || sudo -n true 2>/dev/null; then
        return 0
    fi

    log_info "Administrator access is needed for Homebrew and the Xcode command line tools"
    sudo -v

    local parent_pid="$$"
    (
        while kill -0 "$parent_pid" 2>/dev/null; do
            sudo -n true 2>/dev/null
            sleep 50
        done
    ) &
}

# clones one of GITHUB_USER's public repositories unless it is already there, so a re-run never
# touches work in progress. Plain git over HTTPS, so no GitHub sign-in is needed
clone_repository() {
    local repository="$1"
    local target="$2"

    if [[ -d "$target/.git" ]]; then
        log_info "Already cloned: $target"
        return 0
    fi

    mkdir -p "$(dirname "$target")"
    git clone "https://github.com/${GITHUB_USER}/${repository}.git" "$target"
}

# every config lives in a folder of the one dotfiles clone, so each step that needs one makes sure
# the clone is there first and a stage run on its own still works
clone_dotfiles() {
    clone_repository dotfiles "$DOTFILES_DIR"
}

# a replaced file goes to the Bin rather than being kept as a copy, so a run leaves no backups
# behind while anything replaced by mistake can still be restored
move_to_trash() {
    local target="$1"
    mkdir -p "${HOME}/.Trash"
    mv "$target" "${HOME}/.Trash/$(basename "$target")-$(date +%Y%m%d-%H%M%S)"
}

# links a file or folder into place. An existing real one is moved to the Bin first

link_file() {
    local source="$1"
    local target="$2"

    if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
        log_info "Already linked: $target"
        return 0
    fi

    if [[ -e "$target" && ! -L "$target" ]]; then
        move_to_trash "$target"
        log_warn "Moved the existing $target to the Bin"
    fi

    mkdir -p "$(dirname "$target")"
    ln -sfn "$source" "$target"
    log_success "Linked $target"
}

# checks that every command given is on PATH and names each missing one before failing
verify_commands() {
    local label="$1"
    shift
    local command_name
    local missing=0

    for command_name in "$@"
    do
        if ! command -v "$command_name" >/dev/null 2>&1; then
            log_error "${label} command is unavailable: ${command_name}"
            missing=1
        fi
    done

    if (( missing )); then
        return 1
    fi

    log_success "${label} verified successfully"
}

run_stage() {
    local stage_name="$1"
    local stage_path="$2"

    if [[ ! -x "$stage_path" ]]; then
        log_error "Stage is missing or not executable: $stage_path"
        return 1
    fi

    log_info "Running stage: $stage_name"
    # shellcheck disable=SC1090
    source "$stage_path"
    printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$stage_name" >> "${BOOTSTRAP_STATE_DIR}/stages.log"
    log_success "Completed stage: $stage_name"
}
