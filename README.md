# Dotfiles

Personal development environment managed with [GNU Stow](https://www.gnu.org/software/stow/) and [Homebrew](https://brew.sh/).

## Features

- **Zinit** — Fast ZSH plugin manager with lazy loading
- **Starship** — Cross-shell prompt with Dracula theme
- **fzf** — Fuzzy finder with custom keybindings
- **eza** — Modern `ls` replacement
- **Platform-aware** — Conditional configs for macOS/Linux/containers
- **Tiered installation** — Minimal, dev, or full Mac restoration

## Structure

```text
dotfiles/
├── zsh/                        # ZSH stow package
│   ├── .zprofile               # Login shell config (ssh-agent, brew)
│   ├── .zshrc                  # Interactive shell config (zinit, plugins)
│   └── .config/
│       ├── aliases.zsh         # Shell aliases
│       ├── alacritty/          # Terminal emulator config
│       ├── bat/                # Cat replacement config
│       ├── eza/                # Ls replacement theme
│       ├── fzf/                # Fuzzy finder config
│       ├── neofetch/           # System info display
│       ├── ruff/               # Python linter config
│       └── starship/           # Prompt config
├── Brewfile.dev                # Core CLI tools for dev environments
├── Brewfile                    # Full Mac restoration (imports Brewfile.dev)
├── install.sh                  # Bootstrap script
└── README.md
```

## Installation

### Installation Modes

| Mode    | Command              | Use Case                                     |
|---------|----------------------|----------------------------------------------|
| Minimal | `./install.sh`       | Just stow, symlink configs                   |
| Dev     | `./install.sh --dev` | Devcontainer/VM: core CLI tools              |
| Full    | `./install.sh --full`| New Mac: all tools, apps, fonts, extensions  |

### Quick Install

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh          # Minimal
./install.sh --dev    # Dev environment
./install.sh --full   # Full Mac setup
```

### List Available Packages

```bash
./install.sh --list
```

### Devcontainer / Cloud VM

Add to your devcontainer.json:

```json
{
  "postCreateCommand": "git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles && ~/dotfiles/install.sh --dev"
}
```

## Brewfiles

### Brewfile.dev (Dev Environment)

Core CLI tools that work on macOS and Linux:

- git, stow, make
- eza, bat, tree
- gh, just, tldr
- lazydocker
- zsh-completions

### Brewfile (Full Mac)

Everything in Brewfile.dev plus:

- **Languages**: pyenv, node, rust, python versions
- **Build tools**: cmake, boost, llvm
- **Apps**: tmux, neofetch, imagemagick
- **Casks**: orbstack, fonts
- **VS Code extensions**: Python, Jupyter, Docker, themes

### Updating Brewfiles

```bash
# Regenerate from current system
brew bundle dump --file=~/dotfiles/Brewfile --force

# Install from Brewfile
brew bundle install --file=~/dotfiles/Brewfile
```

## Usage

### Stow Commands

```bash
# Apply symlinks
cd ~/dotfiles && stow zsh

# Remove symlinks
cd ~/dotfiles && stow -D zsh

# Re-stow (remove then apply)
cd ~/dotfiles && stow -R zsh

# Preview changes (dry run)
cd ~/dotfiles && stow -n -v zsh

# Unstow all packages
./install.sh --unstow
```

### Local Overrides

For machine-specific configuration not tracked in git:

```bash
~/.config/local.zsh
```

This file is sourced at the end of `.zshrc` if it exists.

Example uses:

- Machine-specific PATH additions (e.g., IDE paths)
- Work-specific aliases
- Local environment variables

## Platform Support

| Feature          | macOS | Linux | Container      |
|------------------|-------|-------|----------------|
| Homebrew init    | ✅    | ✅    | ✅             |
| pyenv            | ✅    | ❌    | ❌             |
| SSH agent init   | ✅    | ✅    | ❌ (forwarded) |
| Zinit plugins    | ✅    | ✅    | ✅             |
| Starship         | ✅    | ✅    | ✅             |
| Casks (GUI apps) | ✅    | ❌    | ❌             |

Container detection skips pyenv and SSH agent initialization when running in devcontainers, Codespaces, or Docker.

## Adding New Stow Packages

1. Create a new directory: `mkdir -p ~/dotfiles/nvim/.config/nvim`
2. Add config files mirroring home structure
3. Stow: `cd ~/dotfiles && stow nvim`
4. Add to `stow_packages()` in install.sh

## Troubleshooting

### Conflicts during stow

If stow reports conflicts, existing files need to be moved:

```bash
# Backup and retry
mv ~/.zshrc ~/.zshrc.bak
cd ~/dotfiles && stow zsh
```

The install script automatically backs up conflicting files.

### Zinit not loading

Ensure git is installed and `~/.local/share/zinit` is writable.

### Missing completions

Run `update_zsh_completions` after installing new CLI tools.

### Brewfile out of sync

```bash
# See what's missing
brew bundle check --file=~/dotfiles/Brewfile

# Install missing packages
brew bundle install --file=~/dotfiles/Brewfile
```
