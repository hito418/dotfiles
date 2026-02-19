#!/usr/bin/env bash

apply_symlinks() {
  local -r config="$DOTFILES_PATH/conf/$1"

  if [[ ! -f "$config" ]]; then
    log::error "Symlink config not found: $config"
    return 1
  fi

  while IFS='=' read -r target source; do
    [[ -z "$target" || "$target" =~ ^[[:space:]]*# ]] && continue

    target=$(echo "$target" | xargs)
    source=$(echo "$source" | xargs)
    target="${target/#\~/$HOME}"
    source="$DOTFILES_PATH/$source"

    mkdir -p "$(dirname "$target")"
    if [[ -d "$target" && ! -L "$target" ]]; then
      rm -rf "$target"
    fi
    ln -sfn "$source" "$target"
    log::success "Linked $target → $source"
  done < "$config"
}

apply_common_symlinks() {
  apply_symlinks "symlinks.conf"
}
