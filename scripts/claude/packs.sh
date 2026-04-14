#!/usr/bin/env bash

readonly PACKS_DIR="$DOTFILES_PATH/conf/claude/packs"
readonly AGENTS_DIR="$DOTFILES_PATH/claude/agents"

# Directory-symlink resources: name → source directory under claude/
declare -rA RESOURCES=(
    [rules]="$DOTFILES_PATH/claude/rules"
    [skills]="$DOTFILES_PATH/claude/skills"
)

packs::is_resource() {
    [[ -n "${RESOURCES[$1]:-}" ]]
}

packs::resolve_target() {
    local -r scope="$1"  # "global" or "project"
    case "$scope" in
        project) echo "$(pwd)/.claude" ;;
        global)  echo "$HOME/.claude" ;;
        *) log::error "Unknown scope: $scope"; return 1 ;;
    esac
}

packs::install_resource() {
    local -r name="$1"
    local -r target_base="$2"
    local -r source="${RESOURCES[$name]}"
    local -r link="$target_base/$name"

    mkdir -p "$target_base"

    if [[ -L "$link" && "$(readlink "$link")" == "$source" ]]; then
        log::note "$name already linked"
        return 0
    fi
    if [[ -e "$link" && ! -L "$link" ]]; then
        log::error "$link exists and is not a symlink; refusing to overwrite"
        return 1
    fi
    ln -sfn "$source" "$link"
    log::success "Linked $name → $link"
}

packs::uninstall_resource() {
    local -r name="$1"
    local -r target_base="$2"
    local -r link="$target_base/$name"

    if [[ -L "$link" ]]; then
        rm "$link"
        log::success "Removed $name symlink"
    else
        log::note "$name not linked at $link"
    fi
}

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

packs::parse_names() {
    local result=()
    for arg in "$@"; do
        while IFS= read -r name; do
            [[ -n "$name" ]] && result+=("$name")
        done <<< "$(str::split "$arg" ",")"
    done
    printf '%s\n' "${result[@]}"
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

    # Show core first with user-scope hint
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
        log::note "No agents installed in this project"
        return
    fi

    local found=false
    for link in "$target_dir"/*.md; do
        [[ -e "$link" ]] || continue
        found=true
        printf "  %s\n" "$(basename "$link" .md)"
    done

    if ! $found; then
        log::note "No agents installed in this project"
    fi
}
