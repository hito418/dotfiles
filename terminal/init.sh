ulimit -n 200000 2>/dev/null || true
ulimit -u 2048 2>/dev/null || true

# Enable aliases to be sudo'ed
alias sudo='sudo '

# Register all aliases
for aliasToSource in "$DOTFILES_PATH/terminal/_aliases/"*; do source "$aliasToSource"; done
