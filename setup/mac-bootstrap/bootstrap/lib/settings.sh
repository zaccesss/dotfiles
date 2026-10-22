#!/usr/bin/env bash
#
# macOS settings live in the dotfiles' setup/defaults folder, which holds the tracked key list, the values
# captured from a real Mac and the script that captures and applies them. Keeping both there means
# one source of truth for every machine's settings

readonly DEFAULTS_DIR="${DOTFILES_DIR}/setup/defaults"
readonly DEFAULTS_SCRIPT="${MAC_BOOTSTRAP_DEFAULTS_SCRIPT:-${DEFAULTS_DIR}/mac/defaults.sh}"

apply_settings() {
    clone_dotfiles
    /bin/bash "$DEFAULTS_SCRIPT"
}

capture_settings() {
    clone_dotfiles
    /bin/bash "$DEFAULTS_SCRIPT" --capture
    log_info "Commit the updated setup/defaults/mac/defaults.tsv in ${DOTFILES_DIR}, in your own fork"
}
