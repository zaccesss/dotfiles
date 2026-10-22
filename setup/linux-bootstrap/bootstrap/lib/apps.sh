#!/usr/bin/env bash
#
# the last stage: every editor and app found on this machine gets its settings from its own apply
# script in the dotfiles clone, the same scripts zt runs, so a fresh machine and a theme switch
# write the same files. the clone comes from the configs extra, so without it the stage says so
# and stops. each app is one line of output and the scripts' own detail goes to apps.log in the state
# folder. every script refuses to run while its app is open, which is reported as a skip, so
# running --apps-only after quitting the app finishes the job

readonly APPS_LOG="${BOOTSTRAP_STATE_DIR}/apps.log"
APPS_THEME=""

# true when the desktop is in dark mode, asked the same way zt asks: KDE's colour scheme, then
# GNOME's colour-scheme key. with no desktop to ask (a server, WSL or OrbStack) dark is the default
desktop_is_dark() {
    local tool scheme
    if [[ "${XDG_CURRENT_DESKTOP:-}" == *[Kk][Dd][Ee]* ]]; then
        for tool in kreadconfig6 kreadconfig5; do
            if command -v "$tool" >/dev/null 2>&1; then
                scheme="$("$tool" --file kdeglobals --group General --key ColorScheme 2>/dev/null || true)"
                [[ "${scheme,,}" == *dark* ]]
                return
            fi
        done
    fi
    if command -v gsettings >/dev/null 2>&1 \
        && scheme="$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)"; then
        [[ "$scheme" == *dark* ]]
        return
    fi
    return 0
}

# the theme zt last set, so a re-run matches it instead of putting every app back on the default.
# "auto <dark> <light>" picks by the desktop's appearance. with no state file nothing is printed and
# each script keeps its own default
zacess_theme() {
    local state="${XDG_STATE_HOME:-${HOME}/.local/state}/zacess/theme"
    local mode="" dark="" light=""

    [[ -f "$state" ]] || return 0
    read -r mode dark light < "$state" || true
    if [[ "$mode" != "auto" ]]; then
        printf '%s\n' "$mode"
    elif desktop_is_dark; then
        printf '%s\n' "${dark:-deep-contrast-dark}"
    else
        printf '%s\n' "${light:-deep-contrast-light}"
    fi
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
    local script="${CONFIG_DOTFILES_DIR}/$2"
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

    output="$(bash "$script" "${args[@]}" 2>&1)" || status=$?
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

apply_installed_apps() {
    local config="${XDG_CONFIG_HOME:-${HOME}/.config}"
    local roaming

    if [[ ! -d "$CONFIG_DOTFILES_DIR" ]]; then
        log_info "No dotfiles clone at ${CONFIG_DOTFILES_DIR} (the configs extra makes one), app settings skipped"
        return 0
    fi
    mkdir -p "$BOOTSTRAP_STATE_DIR"
    APPS_THEME="$(zacess_theme)"
    if [[ -n "$APPS_THEME" ]]; then
        log_info "Applying app settings with the theme zt last set: ${APPS_THEME}"
    fi

    # Zed's script adds the theme file and sets the theme in its settings.json. the Flatpak build
    # keeps its own config folder
    if command -v zed >/dev/null 2>&1 || any_exists "${config}/zed" "${HOME}/.var/app/dev.zed.Zed/config/zed"; then
        apply_app Zed editors/zed/linux/apply.sh theme
    else
        skip_app Zed
    fi

    # an IDE has a config folder with options/ once it has been started
    if any_exists "${config}"/JetBrains/*/options; then
        apply_app JetBrains editors/jetbrains/linux/apply.sh theme
    else
        skip_app JetBrains "not installed or not started once"
    fi

    # both merge into a workspace the IDE has opened once, so no workspace means not set up yet
    if [[ -d "${HOME}/eclipse-workspace/.metadata" ]]; then
        apply_app Eclipse editors/eclipse/apply.sh theme
    else
        skip_app Eclipse "no workspace yet"
    fi
    if any_exists "${HOME}"/STM32CubeIDE/workspace_*/.metadata; then
        apply_app STM32CubeIDE editors/stm32cubeide/linux/apply.sh theme
    else
        skip_app STM32CubeIDE "no workspace yet"
    fi

    if any_exists "${HOME}/.arduinoIDE/settings.json" "${HOME}/.var/app/cc.arduino.IDE2/.arduinoIDE/settings.json"; then
        apply_app "Arduino IDE" editors/arduino/linux/apply.sh theme
    else
        skip_app "Arduino IDE" "not installed or not started once"
    fi

    # KiCad, Processing and Vivado check for themselves and report a skip
    apply_app KiCad editors/kicad/linux/apply.sh theme

    # LTspice runs under Wine and keeps its ini in the Wine prefix's roaming folder
    roaming="${WINEPREFIX:-${HOME}/.wine}/drive_c/users/${USER:-$(id -un)}/AppData/Roaming"
    if any_exists "${roaming}/LTspice.ini" "${roaming}/LTspiceXVII.ini"; then
        apply_app LTspice editors/ltspice/linux/apply.sh theme
    else
        skip_app LTspice "not installed or not started once"
    fi

    if any_exists /usr/local/MATLAB/R20* || command -v matlab >/dev/null 2>&1; then
        apply_app MATLAB editors/matlab/linux/apply.sh theme
    else
        skip_app MATLAB
    fi

    apply_app Processing editors/processing/linux/apply.sh theme

    if any_exists "${config}/Thonny/configuration.ini" "${HOME}/.var/app/org.thonny.Thonny/config/Thonny/configuration.ini"; then
        apply_app Thonny editors/thonny/linux/apply.sh theme
    else
        skip_app Thonny "not installed or not started once"
    fi

    apply_app Vivado editors/vivado/linux/apply.sh theme

    # a vault can live anywhere, so it is named once in OBSIDIAN_VAULT, which zt and the apply
    # script read too
    if [[ -n "${OBSIDIAN_VAULT:-}" && -d "${OBSIDIAN_VAULT}/.obsidian" ]]; then
        apply_app Obsidian apps/obsidian/linux/apply.sh theme
    else
        skip_app Obsidian "no vault named in OBSIDIAN_VAULT"
    fi

    if any_exists "${HOME}"/.zotero/zotero/*/prefs.js "${HOME}"/.var/app/org.zotero.Zotero/.zotero/zotero/*/prefs.js; then
        apply_app Zotero apps/zotero/linux/apply.sh theme
    else
        skip_app Zotero "not installed or not started once"
    fi
}
