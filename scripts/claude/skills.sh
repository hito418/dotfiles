#!/usr/bin/env bash

readonly SKILLS_SOURCE="$DOTFILES_PATH/claude/skills"

skills::names() {
    local d
    for d in "$SKILLS_SOURCE"/*/; do
        [[ -d "$d" ]] && basename "$d"
    done
}

skills::_migrate_dir_symlink() {
    local -r dir="$1"
    if [[ -L "$dir" ]]; then
        rm "$dir"
        log::note "Removed legacy dir-symlink at $dir"
    fi
}

skills::install() {
    local -r name="$1"
    local -r target_base="$2"
    local -r src="$SKILLS_SOURCE/$name"
    local -r dir="$target_base/skills"
    local -r link="$dir/$name"

    if [[ ! -d "$src" ]]; then
        log::error "Unknown skill: $name"
        return 1
    fi

    skills::_migrate_dir_symlink "$dir"
    mkdir -p "$dir"

    if [[ -L "$link" && "$(readlink "$link")" == "$src" ]]; then
        log::note "Skill already linked: $name"
        return 0
    fi
    if [[ -e "$link" && ! -L "$link" ]]; then
        log::error "$link exists and is not a symlink; refusing to overwrite"
        return 1
    fi
    ln -sfn "$src" "$link"
    log::success "Linked skill: $name"
}

skills::uninstall() {
    local -r name="$1"
    local -r target_base="$2"
    local -r dir="$target_base/skills"
    local -r link="$dir/$name"

    if [[ -L "$link" ]]; then
        rm "$link"
        log::success "Removed skill: $name"
    else
        log::note "Skill not linked: $name"
    fi

    if [[ -d "$dir" && ! -L "$dir" && -z "$(ls -A "$dir")" ]]; then
        rmdir "$dir"
        log::note "Removed empty $dir"
    fi
}

skills::list_available() {
    local name
    while IFS= read -r name; do
        printf "  %s\n" "$name"
    done < <(skills::names)
}

skills::list_installed() {
    local -r target_base="$1"
    local -r dir="$target_base/skills"

    if [[ -L "$dir" ]]; then
        log::note "Legacy dir-symlink: $dir → $(readlink "$dir")"
        log::note "Run 'dot claude skills add <name>' to migrate to per-skill symlinks"
        return
    fi
    if [[ ! -d "$dir" ]]; then
        log::note "No skills installed"
        return
    fi

    local found=false link
    for link in "$dir"/*; do
        [[ -L "$link" ]] || continue
        found=true
        printf "  %s\n" "$(basename "$link")"
    done
    $found || log::note "No skills installed"
}
