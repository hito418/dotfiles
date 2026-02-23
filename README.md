# Hito personal dotfiles

Configuration files and scripts for setting up and maintaining a development environment on Linux (WSL2).

## What's included

| Directory    | Description                                                      |
| ------------ | ---------------------------------------------------------------- |
| `bin/`       | The `dot` CLI — main entry point for managing dotfiles           |
| `claude/`    | Claude Code agents, skills, rules, and settings                  |
| `conf/`      | Symlink mappings, APT package lists, and agent pack definitions  |
| `git/`       | Git configuration, aliases, and attributes                       |
| `scripts/`   | Core automation: bootstrap, update, package install, symlinks    |
| `ssh/`       | SSH client config with connection multiplexing and keep-alive    |
| `terminal/`  | Zsh setup, aliases, functions, themes, and plugins               |
| `tmux/`      | Tmux config with C-a prefix and vim-style navigation             |
| `vim/`       | Vim config with sensible defaults                                |

## Installation

On a fresh system:

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/hito418/dotfiles/main/installer)
```

This clones the repo, installs packages, creates symlinks, sets up Oh My Zsh, installs Claude Code with agents and MCP servers, and configures zsh as the default shell.

## Usage

```sh
dot self bootstrap   # initial setup (packages, symlinks, Claude Code, git, zsh)
dot self update      # pull latest changes, update packages and symlinks
dot packages install # install packages from conf/apt.conf
dot git setup        # configure git identity and GPG signing
dot doc gpg          # show GPG signing guide
dot claude add <packs>...    # install agent packs into current project
dot claude remove <packs>... # remove agent packs from current project
dot claude list              # show available packs and installed agents
dot claude mcp               # interactive MCP server setup
```

## Key packages

git, zsh, tmux, vim, bat, curl, fzf, ripgrep, fd-find, direnv, zoxide, jq

## Configuration details

### Git

- Aliases: `st`, `co`, `sw`, `br`, `ci`, `unstage`, `last`, `visual` (graph log)
- Rebase on pull, auto-correct typos, delta pager, prune on fetch
- Diff drivers for JSON, PNG, and JPG via `.gitattributes`
- Supports machine-specific overrides via `~/.gitconfig.local`

### Vim

- Relative line numbers, cursor line highlight, sign column
- Smart search: case-insensitive until you type uppercase
- 4-space indentation (2-space for JS/TS/HTML/CSS/JSON/YAML)
- Persistent undo history, no swap or backup files
- Split navigation with `C-h/j/k/l`, mouse and clipboard support

### Tmux

- `C-a` prefix, `|` and `-` for splits (in current directory)
- Vim-like pane navigation (`h/j/k/l`) and resize (`H/J/K/L`)
- Vi copy mode, mouse support, 256-color, 50k line history
- 1-indexed windows, minimal status bar, `r` to reload config

### SSH

- Connection multiplexing with persistent sockets (10 min)
- Keep-alive every 60s, auto-add keys to agent, `IdentitiesOnly`
- Machine-specific overrides via `config.local`

### Terminal (Zsh)

- Oh My Zsh with plugins: git, sudo, command-not-found, docker, zsh-autosuggestions, zsh-syntax-highlighting
- fzf integration with fd for file finding and bat for previews
- direnv and zoxide (`z`) for directory navigation
- Custom key bindings: `Ctrl-H` backward-kill-word, `Ctrl-Shift-Delete` kill-word

### Aliases

| Alias | Command    |
| ----- | ---------- |
| `..`  | `cd ..`    |
| `...` | `cd ../..` |
| `ll`  | `ls -l`    |
| `la`  | `ls -laA`  |
| `cl`  | `clear`    |

### Functions

- **`extract <file>`** — automatically extracts any common archive format (tar, gz, zip, 7z, rar, xz, zst, etc.)

## Claude Code

Bootstrap installs Claude Code with the `claude-md-management` plugin and sets up MCP servers interactively.

### Agent packs

Agents are organized into packs that can be installed per-project with `dot claude add <pack>`:

| Pack         | Agents                                                                           |
| ------------ | -------------------------------------------------------------------------------- |
| `core`       | code-reviewer, debugger, git-workflow, context-manager, dx-optimizer, agent-organizer |
| `backend`    | backend-architect, backend-developer                                             |
| `frontend`   | frontend-developer, product-designer                                             |
| `fullstack`  | full-stack-developer, frontend-developer, product-designer, backend-architect, backend-developer |
| `react`      | react-pro                                                                        |
| `typescript` | typescript-pro                                                                   |
| `devops`     | performance-monitor, architect-reviewer                                          |
| `docs`       | api-documenter, documentation-expert                                             |

The `core` pack is installed globally during bootstrap. Other packs are project-local.

### Skills

| Skill            | Description                                           |
| ---------------- | ----------------------------------------------------- |
| `/commit`        | Atomic conventional commits grouped by logical concern |
| `/create-pr`     | GitHub PR with auto-detected base and structured body |
| `/create-mr`     | GitLab MR with auto-detected target and linked issues |
| `/create-issue`  | GitHub issue via gh CLI                               |
| `/create-issue-gl` | GitLab issue via glab CLI                           |
| `/create-skill`  | Guide for creating new skills                         |

### MCP servers

Configured interactively via `dot claude mcp`:

- **Context7** — up-to-date library documentation
- **GitHub** — repository, issue, and PR tools
- **GitLab** — merge request, issue, and pipeline tools
