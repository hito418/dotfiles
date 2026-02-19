# Dotfiles path
export DOTFILES_PATH="$HOME/.dotfiles"

# PATH
export PATH="$HOME/.local/bin:$DOTFILES_PATH/bin:$PATH"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="zsh"
plugins=(git sudo command-not-found)
source "$ZSH/oh-my-zsh.sh"

# fzf
if command -v fzf &>/dev/null; then
  [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
  [[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && source /usr/share/doc/fzf/examples/completion.zsh
  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
  if command -v batcat &>/dev/null; then
    export FZF_CTRL_T_OPTS="--preview 'batcat --style=numbers --color=always {}'"
  elif command -v bat &>/dev/null; then
    export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always {}'"
  fi
fi

# Dotfiles terminal init (aliases, ulimits, etc.)
source "$DOTFILES_PATH/terminal/init.sh"
