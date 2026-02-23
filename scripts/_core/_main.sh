#!/usr/bin/env bash

if ! ${DOT_MAIN_SOURCED:-false}; then
  source "$DOTFILES_PATH/scripts/_core/documentation.sh"
  source "$DOTFILES_PATH/scripts/_core/log.sh"
  source "$DOTFILES_PATH/scripts/_core/platform.sh"
  source "$DOTFILES_PATH/scripts/_core/str.sh"

  readonly DOT_MAIN_SOURCED=true
fi
