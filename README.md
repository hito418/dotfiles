# Hito personal dotfiles

Configuration files and scripts for setting up and maintaining a development environment on Linux (WSL2).

## What's included

| Directory    | Description                                                      |
| ------------ | ---------------------------------------------------------------- |
| `bin/`       | The `dot` CLI — main entry point for managing dotfiles           |
| `claude/`    | Claude Code agents, skills, rules, and settings                  |
| `conf/`      | Symlink mappings, APT package lists, and agent pack definitions  |
| `git/`       | Git configuration, aliases, and attributes                       |
| `scripts/`   | Core automation: install, package management, symlinks           |
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
dot self install      # install or update dotfiles (idempotent)
dot packages install # install packages from conf/apt.conf
dot git setup        # configure git identity and GPG signing
dot doc gpg          # show GPG signing guide
dot claude packs  {add|remove|list} [--project] [<pack>...]   # agent packs
dot claude rules  {add|remove|list} [--project] [<rule>...]   # rule files
dot claude skills {add|remove|list} [--project] [<skill>...]  # skill dirs
dot claude mcp                                                # MCP setup

# --project targets ./.claude/ instead of ~/.claude/ (created if missing).
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

`dot self install` installs Claude Code with the `claude-md-management` plugin and checks MCP server configuration.

### Rules, skills and agent packs

Rules (`claude/rules/*.md`), skills (`claude/skills/*/`) and agent packs install into `~/.claude/` as per-item symlinks. Three parallel subcommands — `packs`, `rules`, `skills` — each support `add`, `remove`, `list`, with an optional `--project` flag to target `./.claude/` instead.

```sh
dot claude rules  add git process         # link git.md + process.md globally
dot claude skills add commit create-pr    # link two skills globally
dot claude packs  add fullstack           # install the fullstack agent pack
dot claude rules  add --project code-style  # project-scoped
dot claude skills list --project            # what's installed here?
```

Agents are organized into packs:

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

The `core` pack is installed globally during `dot self install`. Rules, skills and other packs are opt-in via the subcommands above.

### Skills

| Skill            | Description                                                    |
| ---------------- | -------------------------------------------------------------- |
| `/commit`        | Atomic conventional commits grouped by logical concern         |
| `/create-pr`     | GitHub PR or GitLab MR, auto-detected from the git remote      |
| `/create-issue`  | GitHub or GitLab issue, auto-detected from the git remote      |
| `/review-pr`     | Triage unresolved PR/MR comments, fix relevant ones, resolve rest |
| `/create-skill`  | Guide for creating new skills                                  |

### MCP servers

Configured interactively via `dot claude mcp`:

- **Context7** — up-to-date library documentation
- **GitHub** — repository, issue, and PR tools
- **GitLab** — merge request, issue, and pipeline tools
