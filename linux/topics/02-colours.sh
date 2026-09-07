# =============================================================================
# Colour variables
# Same variables as the mac profile so functions work identically on Linux.
# Used by cls(), cmds() and any function that prints formatted output.
# =============================================================================

# shellcheck disable=SC2034
# These variables are used across sourced topic files - shellcheck can't see cross-file usage.
# RED=errors  GREEN=success  CYAN=progress/info  YELLOW=warnings/date  MAGENTA=cmds headers  WHITE=cmds descriptions
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
WHITE='\033[0;37m'
BOLD='\033[1m'
RESET='\033[0m'

# =============================================================================
# Prompt
# \[...\] wrappers mark zero-width sequences so bash measures line length correctly.
# user@host in cyan, path in yellow, $ in green.
# =============================================================================

# shellcheck disable=SC2025
PS1="\[\033[0;36m\]\u@\h\[\033[0m\] \[\033[1;33m\]\w\[\033[0m\] \[\033[0;32m\]\$\[\033[0m\] "

# =============================================================================
# Coloured output
# GNU ls and diff both support --color=auto. grep's own colour alias lives in
# 07-utilities.sh alongside the rest of that file's everyday command tweaks.
# =============================================================================

alias ls='ls --color=auto'
alias diff='diff --color=auto'

# Coloured man pages via less TERMCAP variables.
export LESS="-R"
export LESS_TERMCAP_mb=$'\033[1;32m'
export LESS_TERMCAP_md=$'\033[1;36m'
export LESS_TERMCAP_me=$'\033[0m'
export LESS_TERMCAP_se=$'\033[0m'
export LESS_TERMCAP_so=$'\033[1;33m'
export LESS_TERMCAP_ue=$'\033[0m'
export LESS_TERMCAP_us=$'\033[4;32m'
