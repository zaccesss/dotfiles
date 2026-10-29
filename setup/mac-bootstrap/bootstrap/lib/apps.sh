#!/usr/bin/env bash
#
# the last stage: every editor and app found on this Mac gets its settings from its own apply
# script in the dotfiles clone, the same scripts zt runs, so a fresh Mac and a theme switch write
# the same files. each app is one line of output and the scripts' own detail goes to apps.log in the
# state folder. every script refuses to run while its app is open, which is reported as a skip, so
# running --apps-only after quitting the app finishes the job. Written for bash 3.2

readonly APPLICATIONS_DIR="${MAC_BOOTSTRAP_APPLICATIONS_DIR:-/Applications}"
readonly APPS_LOG="${BOOTSTRAP_STATE_DIR}/apps.log"
APPS_THEME=""

# the theme zt last set, so a re-run matches it instead of putting every app back on the default.
# "auto <dark> <light>" picks by the current appearance. with no state file nothing is printed and
# each script keeps its own default
zacess_theme() {
    local state="${XDG_STATE_HOME:-${HOME}/.local/state}/zacess/theme"
    local mode="" dark="" light=""

    [[ -f "$state" ]] || return 0
    read -r mode dark light < "$state" || true
    if [[ "$mode" != "auto" ]]; then
        printf '%s\n' "$mode"
    elif [[ "$(defaults read NSGlobalDomain AppleInterfaceStyle 2>/dev/null || true)" == "Dark" ]]; then
        printf '%s\n' "${dark:-deep-contrast-dark}"
    else
        printf '%s\n' "${light:-deep-contrast-light}"
    fi
}

app_installed() {
    [[ -d "${APPLICATIONS_DIR}/$1" || -d "${HOME}/Applications/$1" ]]
}

# succeeds when any of its arguments exists, so an unmatched glob simply fails
any_exists() {
    local path
    for path in "$@"
    do
        [[ -e "$path" ]] && return 0
    done
    return 1
}

skip_app() {
    log_info "${1}: ${2:-not installed}, skipped"
}

# apply_app <label> <script inside the dotfiles clone> [theme] [each]
#   theme  pass the zt theme with --theme
#   each   the script reports several apps, so it only counts as skipped when every line says so;
#          otherwise a first line saying "skipped" means the app is not set up
apply_app() {
    local label="$1"
    local script="${DOTFILES_DIR}/$2"
    local with_theme="${3:-}"
    local rule="${4:-first}"
    local output=""
    local status=0
    local skipped=0
    local -a args=()

    if [[ ! -f "$script" ]]; then
        log_warn "${label}: no apply script at $2, skipped"
        return 0
    fi
    if [[ "$with_theme" == "theme" && -n "$APPS_THEME" ]]; then
        args=(--theme "$APPS_THEME")
    fi

    output="$(bash "$script" ${args[@]+"${args[@]}"} 2>&1)" || status=$?
    printf '== %s %s (exit %s)\n%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$label" "$status" "$output" >> "$APPS_LOG"

    if (( status == 0 )); then
        if [[ "$rule" == "each" ]]; then
            if [[ -n "$output" ]] && ! printf '%s\n' "$output" | grep -v '^Done\.' | grep -qv 'skipped'; then
                skipped=1
            fi
        elif [[ "$(printf '%s\n' "$output" | head -n 1)" == *skipped* ]]; then
            skipped=1
        fi
        if (( skipped )); then
            skip_app "$label" "not set up"
        else
            log_success "${label}: applied"
        fi
    elif [[ "$output" == *"is running"* ]]; then
        log_warn "${label}: open, skipped. Quit it, then run bootstrap.sh --apps-only"
    else
        log_warn "${label}: failed ($(printf '%s\n' "$output" | tail -n 1)), see ${APPS_LOG}"
    fi
}

# Rectangle has no apply script: it offers a RectangleConfig.json in its support folder on its next
# start and renames the file once it is applied. any RectangleConfig file there means the config
# has been offered before, so it is only ever offered once and never overwrites later changes
place_rectangle_config() {
    local folder="${HOME}/Library/Application Support/Rectangle"
    local source="${DOTFILES_DIR}/apps/rectangle/mac/RectangleConfig.json"

    if ! app_installed Rectangle.app; then
        skip_app Rectangle
        return 0
    fi
    if any_exists "$folder"/RectangleConfig*.json; then
        skip_app Rectangle "config already offered once"
        return 0
    fi
    if [[ ! -f "$source" ]]; then
        log_warn "Rectangle: no config at apps/rectangle/mac/RectangleConfig.json, skipped"
        return 0
    fi

    mkdir -p "$folder"
    # a copy, not a link: Rectangle refuses a symlinked or world-writable config file
    cp "$source" "${folder}/RectangleConfig.json"
    chmod 644 "${folder}/RectangleConfig.json"
    log_success "Rectangle: config placed, choose Apply when Rectangle next starts"
}

apply_installed_apps() {
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        log_warn "No dotfiles clone at ${DOTFILES_DIR}, app settings skipped"
        return 0
    fi
    mkdir -p "$BOOTSTRAP_STATE_DIR"
    APPS_THEME="$(zacess_theme)"
    if [[ -n "$APPS_THEME" ]]; then
        log_info "Applying app settings with the theme zt last set: ${APPS_THEME}"
    fi

    # Zed's settings.json is linked by the configs stage; its script adds the theme file and the theme
    if app_installed Zed.app || [[ -d "${HOME}/.config/zed" ]]; then
        apply_app Zed editors/zed/mac/apply.sh theme
    else
        skip_app Zed
    fi

    # an IDE has a config folder with options/ once it has been started
    if any_exists "${HOME}/Library/Application Support/JetBrains"/*/options; then
        apply_app JetBrains editors/jetbrains/mac/apply.sh theme
    else
        skip_app JetBrains "not installed or not started once"
    fi

    if app_installed Xcode.app; then
        apply_app Xcode editors/xcode/apply.sh
    else
        skip_app Xcode
    fi

    # both merge into a workspace the IDE has opened once, so no workspace means not set up yet
    if [[ -d "${HOME}/eclipse-workspace/.metadata" ]]; then
        apply_app Eclipse editors/eclipse/apply.sh theme
    else
        skip_app Eclipse "no workspace yet"
    fi
    if any_exists "${HOME}"/STM32CubeIDE/workspace_*/.metadata; then
        apply_app STM32CubeIDE editors/stm32cubeide/mac/apply.sh theme
    else
        skip_app STM32CubeIDE "no workspace yet"
    fi

    if [[ -f "${HOME}/.arduinoIDE/settings.json" ]]; then
        apply_app "Arduino IDE" editors/arduino/mac/apply.sh theme
    else
        skip_app "Arduino IDE" "not installed or not started once"
    fi

    # KiCad, Processing and Nextpad++ check for themselves and report a skip
    apply_app KiCad editors/kicad/mac/apply.sh theme

    if app_installed LTspice.app; then
        apply_app LTspice editors/ltspice/mac/apply.sh theme
    else
        skip_app LTspice
    fi

    if any_exists "$APPLICATIONS_DIR"/MATLAB_R20*.app || command -v matlab >/dev/null 2>&1; then
        apply_app MATLAB editors/matlab/mac/apply.sh theme
    else
        skip_app MATLAB
    fi

    apply_app Processing editors/processing/mac/apply.sh theme

    if [[ -f "${HOME}/Library/Thonny/configuration.ini" ]]; then
        apply_app Thonny editors/thonny/mac/apply.sh theme
    else
        skip_app Thonny "not installed or not started once"
    fi

    apply_app "Nextpad++" editors/nextpad-plus-plus/mac/apply.sh theme

    # a vault can live anywhere, so it is named once in OBSIDIAN_VAULT, which zt and the apply
    # script read too
    if [[ -n "${OBSIDIAN_VAULT:-}" && -d "${OBSIDIAN_VAULT}/.obsidian" ]]; then
        apply_app Obsidian apps/obsidian/mac/apply.sh theme
    else
        skip_app Obsidian "no vault named in OBSIDIAN_VAULT"
    fi

    if any_exists "${HOME}/Library/Application Support/Zotero/Profiles"/*/prefs.js; then
        apply_app Zotero apps/zotero/mac/apply.sh theme
    else
        skip_app Zotero "not installed or not started once"
    fi

    # Zacess Scenes installs its own release binary, so it needs no app to be present
    apply_app "Zacess Scenes" apps/zacess-scenes/setup.sh

    # Zacess Games installs its own release binary too
    apply_app "Zacess Games" apps/zacess-games/setup.sh

    place_rectangle_config
}
