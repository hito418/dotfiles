##? dot claude - Claude Code rules, skills and agent pack management
##?
##? Usage:
##?    dot claude <resource> <verb> [<args>...]
##?
##? Resources:
##?    packs    Agent packs (core, backend, frontend, react, ...)
##?    rules    Rule files (git, process, code-style, ...)
##?    skills   Skills (commit, create-pr, review-pr, ...)
##?    mcp      Set up MCP servers (leaf command — no verb)
##?
##? Verbs (for packs, rules, skills):
##?    add      Symlink items into target .claude (default: ~/.claude)
##?    remove   Remove item symlinks
##?    list     Show available and installed items
##?
##? Scope:
##?    Pass --project to target ./.claude/ instead of ~/.claude/.
