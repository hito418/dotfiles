#!/usr/bin/env bash

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    log::success "Oh My Zsh is already installed"
    return 0
  fi

  log::note "Installing Oh My Zsh"
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  log::success "Oh My Zsh installed"
}

set_default_shell() {
  local -r zsh_path="$(command -v zsh)"

  if [[ -z "$zsh_path" ]]; then
    log::error "zsh not found in PATH"
    return 1
  fi

  if ! grep -qF "$zsh_path" /etc/shells; then
    echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    log::note "Added $zsh_path to /etc/shells"
  fi

  if [[ "$SHELL" == "$zsh_path" ]]; then
    log::success "zsh is already the default shell"
    return 0
  fi

  chsh -s "$zsh_path"
  log::success "Default shell set to zsh"
}
