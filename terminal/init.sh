ulimit -n 200000 2>/dev/null || true
ulimit -u 2048 2>/dev/null || true

# Ensure SSH sockets directory exists for connection multiplexing
[[ -d ~/.ssh/sockets ]] || { mkdir -p ~/.ssh/sockets && chmod 700 ~/.ssh/sockets; }

# Enable aliases to be sudo'ed
alias sudo='sudo '

# Register all aliases
for aliasToSource in "$DOTFILES_PATH/terminal/_aliases/"*; do source "$aliasToSource"; done

# Register all functions
for funcToSource in "$DOTFILES_PATH/terminal/_functions/"*; do source "$funcToSource"; done
