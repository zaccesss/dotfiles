# fzf shell integration. fzf has no config file of its own: everything is driven by
# FZF_DEFAULT_OPTS and by sourcing the key-bindings and completion scripts its package ships.

export FZF_DEFAULT_COMMAND="rg --files --hidden --glob '!.git/*'"

# colours are terminal colour names (-1 is the terminal's own text and background), so fzf follows
# the terminal's light or dark palette; the current line is bold and reversed in either mode
export FZF_DEFAULT_OPTS="
  --height=60%
  --layout=reverse
  --border
  --color=bg:-1,bg+:-1,fg:-1,fg+:-1:bold:reverse
  --color=hl:yellow:bold,hl+:yellow:bold
  --color=pointer:yellow,marker:yellow
  --color=prompt:-1,spinner:-1,info:-1
  --bind=ctrl-/:toggle-preview
"

if command -v brew >/dev/null 2>&1; then
    FZF_SHELL_DIR="$(brew --prefix fzf 2>/dev/null)/shell"
elif [[ -d "/usr/share/doc/fzf/examples" ]]; then
    FZF_SHELL_DIR="/usr/share/doc/fzf/examples"
fi

[[ -n "${FZF_SHELL_DIR:-}" && -f "$FZF_SHELL_DIR/key-bindings.zsh" ]] && source "$FZF_SHELL_DIR/key-bindings.zsh"
[[ -n "${FZF_SHELL_DIR:-}" && -f "$FZF_SHELL_DIR/completion.zsh" ]] && source "$FZF_SHELL_DIR/completion.zsh"
