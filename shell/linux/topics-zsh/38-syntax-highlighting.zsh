# =============================================================================
# Typed-command colours - zsh-syntax-highlighting
# Loaded last so it wraps the final command line after every alias and function
# is defined. Install: sudo apt install zsh-syntax-highlighting (or the dnf
# equivalent). Silently skipped when the package is absent, so a machine without
# it still gets a clean, working shell.
#
# normal (not bright) ANSI colours because the high contrast palette makes the
# bright variants paler, matching the welcome banner and cmds().
# known command/alias/function/builtin green, unknown-token red, quoted strings
# yellow, options cyan, everything else the terminal's default.
# colour is a second signal only: an unknown command still fails to run, so the
# colour is never the sole indication that something is wrong.
# =============================================================================

# zsh-syntax-highlighting reads this table when it loads below, which shellcheck cannot see
# shellcheck disable=SC2034
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=green'
ZSH_HIGHLIGHT_STYLES[alias]='fg=green'
ZSH_HIGHLIGHT_STYLES[function]='fg=green'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=green'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=green'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[default]='none'

# Ubuntu and Fedora both ship the plugin at this path
_zhl="/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
# shellcheck disable=SC1090
[[ -f "$_zhl" ]] && source "$_zhl"
unset _zhl
