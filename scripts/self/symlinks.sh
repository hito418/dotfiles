#!/usr/bin/env bash

apply_symlinks() {
  local -r config="$DOTFILES_PATH/conf/$1"

  if [[ ! -f "$config" ]]; then
    log::error "Symlink config not found: $config"
    return 1
  fi

  while IFS='=' read -r target src; do
    [[ -z "$target" || "$target" =~ ^[[:space:]]*# ]] && continue

    target="${target#"${target%%[![:space:]]*}"}"
    target="${target%"${target##*[![:space:]]}"}"
    src="${src#"${src%%[![:space:]]*}"}"
    src="${src%"${src##*[![:space:]]}"}"
    target="${target/#\~/$HOME}"
    src="$DOTFILES_PATH/$src"

    mkdir -p "$(dirname "$target")"
    if [[ -d "$target" && ! -L "$target" ]]; then
      log::warning "Replacing directory $target (backed up to ${target}.bak)"
      mv "$target" "${target}.bak"
    fi
    ln -sfn "$src" "$target"
    log::success "Linked $target → $src"
  done < "$config"
}

apply_common_symlinks() {
  apply_symlinks "symlinks.conf"
}
