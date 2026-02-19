# Dotfiles path
export DOTFILES_PATH="$HOME/.dotfiles"

# PATH
export PATH="$HOME/.local/bin:$DOTFILES_PATH/bin:$PATH"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="zsh"
plugins=(git sudo command-not-found)
source "$ZSH/oh-my-zsh.sh"

# Dotfiles terminal init (aliases, ulimits, etc.)
source "$DOTFILES_PATH/terminal/init.sh"
