# =============================================================================
# Command marks - OSC 133 shell integration
# Tells the terminal where each prompt, command and output starts and ends, so
# it can jump from one command to the next and select a single command's
# output: Windows Terminal, tmux and other terminals that read OSC 133 use
# these. Loaded after starship, so the end-of-prompt mark follows the prompt
# starship builds.
# =============================================================================

# a dumb terminal would print the escapes as text. VS Code brings its own OSC 633 marks:
# VSCODE_INJECTION is set while its script sources this profile and VSCODE_SHELL_INTEGRATION
# once the script has run, so either one means the marks are already taken care of
[[ $- == *i* ]] || return 0
[[ "${TERM:-}" == dumb ]] && return 0
[[ -n "${VSCODE_SHELL_INTEGRATION:-}" ]] && return 0
[[ "${TERM_PROGRAM:-}" == vscode && -n "${VSCODE_INJECTION:-}" ]] && return 0

# \[ \] tells bash the mark takes no columns, so the cursor and line wrapping stay right
_cmdmark_end='\[\e]133;B\a\]'

_cmdmark_precmd() {
    local rc=$?
    # D closes the last command with its exit status, only when one ran: an empty Enter
    # never shows PS0, so there is nothing to close
    if [[ -n "${_cmdmark_ran:-}" ]]; then
        printf '\e]133;D;%s\a' "$rc"
        _cmdmark_ran=
    fi
    printf '\e]133;A\a'
    # hand the status on unchanged, so starship (next in PROMPT_COMMAND) still shows it
    return "$rc"
}

_cmdmark_ps1() {
    local rc=$?
    # starship rebuilds PS1 before every prompt, so the end mark goes back on each time
    [[ "$PS1" == *"$_cmdmark_end"* ]] || PS1="${PS1}${_cmdmark_end}"
    return "$rc"
}

# PS0 prints after Enter and before the command runs. the arithmetic inside an empty substring
# sets the ran flag without printing anything, the same trick starship uses for its timer. bash
# skips that arithmetic for an empty variable, so the substring is taken from the always-set
# _cmdmark_on. the single quotes hold it back so it runs at every Enter rather than once here
_cmdmark_on=1
if [[ "${PS0:-}" != *'133;C'* ]]; then
    # shellcheck disable=SC2016
    PS0="${PS0:-}"'${_cmdmark_on:$((_cmdmark_ran=1,0)):0}\e]133;C\a'
fi

# chain onto whatever PROMPT_COMMAND already holds (starship's hook among it) without
# replacing it: the status mark first, before anything else changes $?, the end mark last,
# after starship has rebuilt PS1. bash 5.1 and later also allow it as an array. each
# branch below handles one form, which shellcheck cannot tell apart
# shellcheck disable=SC2128,SC2178
if [[ "$(declare -p PROMPT_COMMAND 2>/dev/null)" == "declare -a"* ]]; then
    if [[ " ${PROMPT_COMMAND[*]} " != *" _cmdmark_precmd "* ]]; then
        PROMPT_COMMAND=(_cmdmark_precmd "${PROMPT_COMMAND[@]}" _cmdmark_ps1)
    fi
elif [[ "${PROMPT_COMMAND:-}" != *_cmdmark_precmd* ]]; then
    PROMPT_COMMAND="_cmdmark_precmd${PROMPT_COMMAND:+$'\n'$PROMPT_COMMAND}"$'\n_cmdmark_ps1'
fi
