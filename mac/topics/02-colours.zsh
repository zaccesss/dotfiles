# =============================================================================
# Colour variables
# I define these once here so every function in every topic file can use them
# without redefining escape codes. BOLD and RESET work alongside any colour.
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
# %F{color}...%f uses zsh native colour escapes (no ANSI wrappers needed).
# user@host in cyan, path in yellow, % in green.
# =============================================================================

PROMPT='%F{cyan}%n@%m%f %F{yellow}%~%f %F{green}%%%f '

# =============================================================================
# Coloured output
# CLICOLOR=1 enables colour in BSD ls (macOS default) without needing -G flag.
# LSCOLORS controls the colour scheme: directories bold cyan, symlinks magenta,
# executables bold green. grep --color=auto highlights matches inline.
# =============================================================================

export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

alias diff='diff --color=auto'

# Coloured man pages via less TERMCAP variables.
# md=bold (section headers), us=underline (emphasis), so=standout (search hits).
export LESS="-R"
export LESS_TERMCAP_mb=$'\033[1;32m'
export LESS_TERMCAP_md=$'\033[1;36m'
export LESS_TERMCAP_me=$'\033[0m'
export LESS_TERMCAP_se=$'\033[0m'
export LESS_TERMCAP_so=$'\033[1;33m'
export LESS_TERMCAP_ue=$'\033[0m'
export LESS_TERMCAP_us=$'\033[4;32m'
