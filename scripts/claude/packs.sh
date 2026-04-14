#!/usr/bin/env bash

readonly PACKS_DIR="$DOTFILES_PATH/conf/claude/packs"
readonly AGENTS_DIR="$DOTFILES_PATH/claude/agents"

packs::read_conf() {
    local -r conf="$1"
    grep -v '^\s*#' "$conf" | grep -v '^\s*$'
}

packs::resolve() {
    local -r name="$1"
    local -r conf="$PACKS_DIR/${name}.conf"

    if [[ ! -f "$conf" ]]; then
        log::error "Unknown pack: $name"
        return 1
    fi

    echo "$conf"
}

packs::find_agent() {
    local -r name="$1"
    local match
    match=$(find "$AGENTS_DIR" -name "${name}.md" -type f 2>/dev/null | head -1)

    if [[ -z "$match" ]]; then
        log::error "Agent not found: $name"
        return 1
    fi

    echo "$match"
}

packs::install() {
    local -r target_dir="$1"
    local -r conf="$2"

    mkdir -p "$target_dir"

    local agent source
    while IFS= read -r agent; do
        source=$(packs::find_agent "$agent") || continue
        if [[ -L "$target_dir/${agent}.md" ]]; then
            continue
        fi
        ln -sfn "$source" "$target_dir/${agent}.md"
        log::success "Linked ${agent}"
    done <<< "$(packs::read_conf "$conf")"
}

packs::uninstall() {
    local -r target_dir="$1"
    local -r conf="$2"

    local agent
    while IFS= read -r agent; do
        if [[ -L "$target_dir/${agent}.md" ]]; then
            rm "$target_dir/${agent}.md"
            log::success "Removed ${agent}"
        fi
    done <<< "$(packs::read_conf "$conf")"

    # Clean up empty directory
    if [[ -d "$target_dir" ]] && [[ -z "$(ls -A "$target_dir")" ]]; then
        rmdir "$target_dir"
        log::note "Removed empty $target_dir"
    fi
}

packs::list_available() {
    local pack agents

    # Core first with user-scope hint
    agents=$(packs::read_conf "$PACKS_DIR/core.conf" | tr '\n' ', ' | sed 's/,$//')
    printf "  %-14s %s  (global)\n" "core" "$agents"

    for conf in "$PACKS_DIR"/*.conf; do
        pack=$(basename "$conf" .conf)
        [[ "$pack" == "core" ]] && continue
        agents=$(packs::read_conf "$conf" | tr '\n' ', ' | sed 's/,$//')
        printf "  %-14s %s\n" "$pack" "$agents"
    done
}

packs::list_installed() {
    local -r target_dir="$1"

    if [[ ! -d "$target_dir" ]]; then
        log::note "No agents installed"
        return
    fi

    local found=false
    for link in "$target_dir"/*.md; do
        [[ -e "$link" ]] || continue
        found=true
        printf "  %s\n" "$(basename "$link" .md)"
    done

    if ! $found; then
        log::note "No agents installed"
    fi
}
