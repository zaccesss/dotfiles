#!/usr/bin/env bash
#
# the tool configs, each a folder of the dotfiles clone, linked into place so an edit in the
# repository applies straight away. Files that hold a person's own name, email, keys and hosts are copied once
# as a starting point instead and never overwritten

# "folder in the dotfiles|path inside the folder|where it is linked"
readonly CONFIG_LINKS=(
    "terminal/tmux|tmux.conf|${HOME}/.tmux.conf"
    "editors/neovim|nvim|${HOME}/.config/nvim"
    "git/git-hooks|mac|${HOME}/.git-hooks"
    "editors/vscode|settings.json|${HOME}/Library/Application Support/Code/User/settings.json"
    "editors/vscode|keybindings/mac.json|${HOME}/Library/Application Support/Code/User/keybindings.json"
    "editors/vscode|global.code-snippets|${HOME}/Library/Application Support/Code/User/snippets/global.code-snippets"
    "editors/zed|settings.json|${HOME}/.config/zed/settings.json"
    "terminal/cli-tools|lazygit/config.yml|${HOME}/Library/Application Support/lazygit/config.yml"
    "terminal/cli-tools|ripgrep/ripgreprc|${HOME}/.ripgreprc"
    "terminal/cli-tools|fzf/fzf.zsh|${HOME}/.config/fzf/fzf.zsh"
)

# "folder in the dotfiles|path inside the folder|where it is copied"
readonly CONFIG_TEMPLATES=(
    "git/gitconfig|mac/gitconfig|${HOME}/.gitconfig"
    "git/ssh|mac/config|${HOME}/.ssh/config"
)

# nano's config is linked only once Homebrew's GNU nano is there: Apple's /usr/bin/nano is Pico,
# which reads no configuration file. The Brewfile stage installs nano after this one, so it calls
# this again and a fresh Mac gets the link in the same run. Tests point this at a stub
link_nano_config() {
    local gnu_nano="${MAC_BOOTSTRAP_GNU_NANO:-${HOMEBREW_PREFIX}/bin/nano}"

    if [[ -x "$gnu_nano" ]]; then
        link_file "${DOTFILES_DIR}/editors/nano/nanorc" "${HOME}/.config/nano/nanorc"
    else
        log_info "GNU nano is not installed yet (Apple's nano is Pico), so its config is left for the Brewfile stage"
    fi
}

install_config_repos() {
    local entry folder inside target

    clone_dotfiles

    for entry in "${CONFIG_LINKS[@]}"
    do
        IFS='|' read -r folder inside target <<< "$entry"
        link_file "${DOTFILES_DIR}/${folder}/${inside}" "$target"
    done
    link_nano_config

    for entry in "${CONFIG_TEMPLATES[@]}"
    do
        IFS='|' read -r folder inside target <<< "$entry"
        if [[ -e "$target" ]]; then
            log_info "Keeping your existing ${target}"
            continue
        fi
        mkdir -p "$(dirname "$target")"
        cp "${DOTFILES_DIR}/${folder}/${inside}" "$target"
        log_warn "Copied a starting ${target}; edit it for your own name, email, keys and hosts"
    done
    chmod 700 "${HOME}/.ssh" 2>/dev/null || true

    # tmux's plugins come from its own plugin manager, which the config expects in this folder
    if [[ ! -d "${HOME}/.tmux/plugins/tpm" ]] && ! is_test_mode; then
        git clone --depth 1 https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
        "${HOME}/.tmux/plugins/tpm/bin/install_plugins" >/dev/null
    fi

    # Terminal.app and iTerm2 keep their profiles in their own preference files, so the terminal
    # folder's installer applies the High Contrast palette rather than a plain link
    if ! is_test_mode; then
        bash "${DOTFILES_DIR}/terminal/terminal/mac/install.sh"
    fi
}
