#!/usr/bin/env bash

readonly CLAUDE_PLUGINS=(claude-md-management@claude-plugins-official)

claude::ensure_installed() {
    if platform::command_exists claude; then
        log::success "Claude Code already installed ($(claude --version 2>/dev/null))"
    else
        curl -fsSL https://claude.ai/install.sh | bash
        log::success "Claude Code installed"
    fi
}

claude::ensure_plugins() {
    local name
    for plugin in "${CLAUDE_PLUGINS[@]}"; do
        name="${plugin%%@*}"
        if claude plugin install "$plugin" -s user 2>&1; then
            log::success "Plugin '$name' installed"
        else
            log::error "Failed to install plugin '$name'"
        fi
    done
}
