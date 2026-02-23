#!/usr/bin/env bash

readonly MCP_SERVERS=(context7 github gitlab)

mcp::is_installed() {
    local -r name="$1"
    claude mcp get "$name" &>/dev/null
}

mcp::ensure_servers() {
    local missing=()

    for server in "${MCP_SERVERS[@]}"; do
        if mcp::is_installed "$server"; then
            log::success "MCP server '$server' is configured"
        else
            missing+=("$server")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        log::note "Missing MCP servers: ${missing[*]}"
        log::note "Run 'dot claude mcp' to set them up"
    fi
}
