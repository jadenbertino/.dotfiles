# bindkey -e # emacs keybindings
bindkey '^F' autosuggest-accept
# ctrl f = accept autosuggestion (via emacs keybindings)
bindkey '^[[A' history-search-backward # up arrow
bindkey '^[[B' history-search-forward # down arrow
export FZF_CTRL_T_COMMAND="" # disable fzf ctrl + t
export FZF_ALT_C_COMMAND="" # disable fzf alt + c
bindkey "^[[1;5C" forward-word # ctrl + right arrow
bindkey "^[[1;5D" backward-word # ctrl + left arrow'

# Cursor keybinds
source "$HOME/.config/zsh/keybinds-cursor.sh"
copy_cursor_config