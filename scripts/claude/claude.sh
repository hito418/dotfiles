#!/usr/bin/env bash

readonly CLAUDE_PLUGINS=(claude-md-management@claude-plugins-official)

claude::ensure_installed() {
    if platform::command_exists claude; then
        log::success "Claude Code is installed ($(claude --version 2>/dev/null))"
    else
        log::note "Installing Claude Code"
        curl -fsSL https://claude.ai/install.sh | bash
    fi
}

claude::ensure_plugins() {
    for plugin in "${CLAUDE_PLUGINS[@]}"; do
        local name="${plugin%%@*}"
        if claude plugin install "$plugin" -s user 2>/dev/null; then
            log::success "Plugin '$name' is installed"
        else
            log::error "Failed to install plugin '$name'"
        fi
    done
}
