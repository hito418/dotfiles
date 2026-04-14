#!/usr/bin/env bash

readonly RULES_SOURCE="$DOTFILES_PATH/claude/rules"

rules::names() {
    local f
    for f in "$RULES_SOURCE"/*.md; do
        [[ -e "$f" ]] && basename "$f" .md
    done
}

rules::_migrate_dir_symlink() {
    local -r dir="$1"
    if [[ -L "$dir" ]]; then
        rm "$dir"
        log::note "Removed legacy dir-symlink at $dir"
    fi
}

rules::install() {
    local -r name="$1"
    local -r target_base="$2"
    local -r src="$RULES_SOURCE/${name}.md"
    local -r dir="$target_base/rules"
    local -r link="$dir/${name}.md"

    if [[ ! -f "$src" ]]; then
        log::error "Unknown rule: $name"
        return 1
    fi

    rules::_migrate_dir_symlink "$dir"
    mkdir -p "$dir"

    if [[ -L "$link" && "$(readlink "$link")" == "$src" ]]; then
        log::note "Rule already linked: $name"
        return 0
    fi
    if [[ -e "$link" && ! -L "$link" ]]; then
        log::error "$link exists and is not a symlink; refusing to overwrite"
        return 1
    fi
    ln -sfn "$src" "$link"
    log::success "Linked rule: $name"
}

rules::uninstall() {
    local -r name="$1"
    local -r target_base="$2"
    local -r dir="$target_base/rules"
    local -r link="$dir/${name}.md"

    if [[ -L "$link" ]]; then
        rm "$link"
        log::success "Removed rule: $name"
    else
        log::note "Rule not linked: $name"
    fi

    if [[ -d "$dir" && ! -L "$dir" && -z "$(ls -A "$dir")" ]]; then
        rmdir "$dir"
        log::note "Removed empty $dir"
    fi
}

rules::list_available() {
    local name
    while IFS= read -r name; do
        printf "  %s\n" "$name"
    done < <(rules::names)
}

rules::list_installed() {
    local -r target_base="$1"
    local -r dir="$target_base/rules"

    if [[ -L "$dir" ]]; then
        log::note "Legacy dir-symlink: $dir → $(readlink "$dir")"
        log::note "Run 'dot claude rules add <name>' to migrate to per-rule symlinks"
        return
    fi
    if [[ ! -d "$dir" ]]; then
        log::note "No rules installed"
        return
    fi

    local found=false link
    for link in "$dir"/*.md; do
        [[ -L "$link" ]] || continue
        found=true
        printf "  %s\n" "$(basename "$link" .md)"
    done
    $found || log::note "No rules installed"
}
