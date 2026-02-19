# Hito personal dotfiles

Configuration files and scripts for setting up and maintaining a development environment on Linux (WSL2).

## What's included

| Directory    | Description                                                      |
| ------------ | ---------------------------------------------------------------- |
| `bin/`       | The `dot` CLI — main entry point for managing dotfiles           |
| `conf/`      | Symlink mappings and APT package lists                           |
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

This clones the repo, installs packages, creates symlinks, sets up Oh My Zsh, and configures zsh as the default shell.

## Usage

```sh
dot self bootstrap   # initial setup
dot self update      # pull latest changes, update packages and symlinks
dot packages install # install packages from conf/apt.conf
```

## Key packages

git, zsh, tmux, vim, bat, curl, fzf, ripgrep, fd-find, direnv, zoxide

## Configuration details

### Git

- Aliases: `st`, `co`, `sw`, `br`, `ci`, `unstage`, `last`, `visual` (graph log)
- Rebase on pull, auto-correct typos, delta pager, prune on fetch
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
- 1-indexed windows, minimal status bar

### SSH

- Connection multiplexing with persistent sockets (10 min)
- Keep-alive every 60s, auto-add keys to agent, `IdentitiesOnly`
- Machine-specific overrides via `config.local`

### Terminal (Zsh)

- Oh My Zsh with plugins: git, sudo, command-not-found, zsh-autosuggestions, zsh-syntax-highlighting
- fzf integration with fd for file finding and bat for previews
- direnv and zoxide (`z`) for directory navigation

### Aliases

| Alias | Command        |
| ----- | -------------- |
| `..`  | `cd ..`        |
| `...` | `cd ../..`     |
| `ll`  | `ls -l`        |
| `la`  | `ls -laA`      |
| `cl`  | `clear`        |

### Functions

- **`extract <file>`** — automatically extracts any common archive format (tar, gz, zip, 7z, rar, xz, zst, etc.)
