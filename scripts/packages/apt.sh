#!/usr/bin/env bash

apt::read_conf() {
  local -r config="$1"

  if [[ ! -f "$config" ]]; then
    log::error "Package config not found: $config"
    return 1
  fi

  local packages=()
  while IFS= read -r line; do
    line="${line%%#*}"
    line=$(echo "$line" | xargs)
    [[ -z "$line" ]] && continue
    packages+=("$line")
  done < "$config"

  echo "${packages[@]}"
}

apt::install_from_conf() {
  local -r config="$DOTFILES_PATH/conf/$1"
  local packages
  read -ra packages <<< "$(apt::read_conf "$config")"

  apt::install_packages "${packages[@]}"
}

apt::install_packages() {
  local missing=()

  for pkg in "$@"; do
    if dpkg -s "$pkg" &>/dev/null; then
      log::success "$pkg is already installed"
    else
      missing+=("$pkg")
    fi
  done

  if [[ ${#missing[@]} -eq 0 ]]; then
    log::success "All packages already installed"
    return 0
  fi

  log::note "Installing: ${missing[*]}"
  if sudo apt install -y "${missing[@]}"; then
    log::success "Installed: ${missing[*]}"
  else
    log::error "Failed to install: ${missing[*]}"
    return 1
  fi
}
