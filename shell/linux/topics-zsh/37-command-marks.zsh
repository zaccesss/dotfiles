# =============================================================================
# Command marks - OSC 133 shell integration
# Tells the terminal where each prompt, command and output starts and ends, so
# it can jump from one command to the next and select a single command's
# output: Windows Terminal (under WSL), tmux and other terminals that read
# OSC 133 use these.
# Loaded after starship, so the end-of-prompt mark follows the prompt starship
# builds. Syntax highlighting loads after this file and must stay last.
# =============================================================================

# a dumb terminal would print the escapes as text. VS Code brings its own OSC 633 marks:
# VSCODE_INJECTION is set while its script sources this profile and VSCODE_SHELL_INTEGRATION
# once the script has run, so either one means the marks are already taken care of
[[ -o interactive ]] || return 0
[[ "${TERM:-}" == dumb ]] && return 0
[[ -n "${VSCODE_SHELL_INTEGRATION:-}" ]] && return 0
[[ "${TERM_PROGRAM:-}" == vscode && -n "${VSCODE_INJECTION:-}" ]] && return 0

# %{ %} tells zsh the mark takes no columns, so the cursor and line wrapping stay right
_cmdmark_end=$'%{\e]133;B\a%}'

_cmdmark_precmd() {
    local rc=$?
    # D closes the last command with its exit status, only when one ran: an empty Enter
    # skips preexec, so there is nothing to close
    if [[ -n "${_cmdmark_ran:-}" ]]; then
        printf '\e]133;D;%s\a' "$rc"
        _cmdmark_ran=
    fi
    printf '\e]133;A\a'
    # a prompt tool can rebuild PROMPT at any time, so the end mark goes back on whenever
    # it is missing rather than once at load
    [[ "$PROMPT" == *"$_cmdmark_end"* ]] || PROMPT="${PROMPT}${_cmdmark_end}"
}

_cmdmark_preexec() {
    _cmdmark_ran=1
    printf '\e]133;C\a'
}

# zsh keeps $? and pipestatus intact across every precmd hook, so starship's hook still
# sees the real status whichever order the two run in
autoload -Uz add-zsh-hook
add-zsh-hook precmd _cmdmark_precmd
add-zsh-hook preexec _cmdmark_preexec
