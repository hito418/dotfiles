#!/usr/bin/env bash

# Check if a named MCP server is already registered with Claude Code.
mcp::is_installed() {
    local -r name="$1"
    claude mcp get "$name" &>/dev/null
}

# Interactive setup for Context7 MCP server.
mcp::setup_context7() {
    log::note "Context7 — library documentation for LLMs"
    read -rsp "Context7 API key (blank to skip): " context7_key
    echo
    if [[ -n "$context7_key" ]]; then
        claude mcp remove -s user context7 2>/dev/null || true
        claude mcp add -s user --transport http \
            --header "CONTEXT7_API_KEY: $context7_key" \
            context7 https://mcp.context7.com/mcp
        log::success "Context7 MCP added"
    else
        log::warning "Skipped"
    fi
}

# Interactive setup for GitHub MCP server.
mcp::setup_github() {
    log::note "GitHub — repository, issue, and PR tools"
    read -rsp "GitHub Personal Access Token (blank to skip): " github_pat
    echo
    if [[ -n "$github_pat" ]]; then
        local json
        json=$(jq -n --arg pat "$github_pat" \
            '{type:"http",url:"https://api.githubcopilot.com/mcp/",headers:{Authorization:("Bearer " + $pat)}}')
        claude mcp remove -s user github 2>/dev/null || true
        claude mcp add-json -s user github "$json"
        log::success "GitHub MCP added"
    else
        log::warning "Skipped"
    fi
}

# Interactive setup for GitLab MCP server.
mcp::setup_gitlab() {
    log::note "GitLab — merge request, issue, and pipeline tools"
    read -rp "Set up GitLab MCP? (y/N) " setup_gitlab
    if [[ "$setup_gitlab" =~ ^[Yy]$ ]]; then
        claude mcp remove -s user gitlab 2>/dev/null || true
        claude mcp add -s user --transport http gitlab https://gitlab.com/api/v4/mcp
        log::success "GitLab MCP added (authenticate via /mcp in Claude Code)"
    else
        log::warning "Skipped"
    fi
}

# Interactive setup for all MCP servers.
mcp::setup_all() {
    mcp::setup_context7
    mcp::setup_github
    mcp::setup_gitlab
}

# Per-server idempotent setup: skip installed servers, prompt for missing ones.
mcp::ensure_all() {
    local -r servers=(context7 github gitlab)
    for server in "${servers[@]}"; do
        if mcp::is_installed "$server"; then
            log::success "MCP server '$server' configured"
        else
            "mcp::setup_$server"
        fi
    done
}
