# Dotfiles

Personal development environment managed with [GNU Stow](https://www.gnu.org/software/stow/) and [Homebrew](https://brew.sh/).

## Quick Start

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh          # Minimal: stow only
./install.sh --dev    # Devcontainer/VM: core CLI tools
./install.sh --full   # New Mac: full restoration
./install.sh --list   # Show what each mode installs
```

### Installation Modes

| Mode    | Command              | Use Case                                     |
|---------|----------------------|----------------------------------------------|
| Minimal | `./install.sh`       | Just stow, symlink configs                   |
| Dev     | `./install.sh --dev` | Devcontainer/VM: core CLI tools              |
| Full    | `./install.sh --full`| New Mac: all tools, apps, fonts, extensions  |

**Devcontainer:** Add to `devcontainer.json`:

```json
{ "postCreateCommand": "git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles && ~/dotfiles/install.sh --dev" }
```

## Structure

Dotfiles are organized into **stow packages** — directories that mirror `$HOME`. Running `stow <package>` symlinks the contents to your home directory.

| Package | Contents                                                                                      |
|---------|-----------------------------------------------------------------------------------------------|
| `zsh/`  | `.zprofile`, `.zshrc`, `.config/` (aliases, alacritty, bat, eza, fzf, neofetch, ruff, starship) |
| `git/`  | `.gitconfig`, `.gitignore_global`                                                             |

**Brewfiles** define installable packages: `Brewfile.dev` contains core CLI tools for any environment, while `Brewfile` imports it and adds macOS-specific items (pyenv, casks, etc.).

## Shell Environment

The ZSH configuration provides a fully customized shell experience:

- **Zinit** — Plugin manager with lazy loading for fast startup
- **Starship** — Minimal, fast prompt with Dracula theme
- **fzf** — Fuzzy finder with custom keybindings (Ctrl+R for history, Ctrl+T for files)
- **fzf-tab** — Tab completion powered by fzf
- **eza** — Modern `ls` with icons and colors
- **bat** — Syntax-highlighted `cat`
- **Auto-completions** — Generated for ruff, poetry, snow, orbctl

## Platform Support

The configuration is platform-aware with conditional logic for different environments:

| Feature        | macOS | Linux | Container      |
|----------------|-------|-------|----------------|
| Homebrew       | ✅    | ✅    | ✅             |
| pyenv          | ✅    | ❌    | ❌             |
| SSH agent init | ✅    | ✅    | ❌ (forwarded) |
| Casks          | ✅    | ❌    | ❌             |

In containers (devcontainers, Codespaces, Docker), pyenv and SSH agent initialization are skipped — pyenv isn't needed, and SSH is forwarded from the host.

## Local Overrides

Machine-specific config not tracked in git:

- `~/.config/local.zsh` — sourced at end of `.zshrc` (e.g., IDE paths, work aliases)
- `~/.config/git/local.config` — included by `.gitconfig` (e.g., editor, signing keys)

## Common Commands

### Stow

```bash
stow zsh                    # Symlink a package to $HOME
stow -D zsh                 # Remove symlinks for a package
stow -R zsh                 # Re-stow (remove + apply)
./install.sh --unstow       # Unstow all packages
```

### Completions

```bash
update_zsh_completions      # Regenerate completions for ruff, poetry, snow, orbctl
```

Run this after updating tools that provide shell completions.

### Brewfile

```bash
brew bundle dump --file=~/dotfiles/Brewfile --force   # Export current packages
brew bundle install --file=~/dotfiles/Brewfile        # Install from Brewfile
brew bundle check --file=~/dotfiles/Brewfile          # Check what's missing
```

## Adding Packages

1. `mkdir -p ~/dotfiles/nvim/.config/nvim`
2. Add config files mirroring `$HOME` structure
3. Add to `stow_packages()` in `install.sh`
4. `stow nvim`
