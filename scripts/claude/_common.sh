#!/usr/bin/env bash

# Shared helpers for the `dot claude` namespace.

claude::resolve_target() {
    local -r scope="$1"
    case "$scope" in
        project) echo "$(pwd)/.claude" ;;
        global)  echo "$HOME/.claude" ;;
        *) log::error "Unknown scope: $scope"; return 1 ;;
    esac
}

claude::parse_names() {
    local result=()
    for arg in "$@"; do
        while IFS= read -r name; do
            [[ -n "$name" ]] && result+=("$name")
        done <<< "$(str::split "$arg" ",")"
    done
    printf '%s\n' "${result[@]}"
}
