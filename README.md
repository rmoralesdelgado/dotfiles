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
- **fzf** — Fuzzy finder with custom keybindings
- **fzf-tab** — Tab completion powered by fzf
- **bat** — Syntax-highlighted `cat`
- **Auto-completions** — Generated for `uv`, `uvx`, `ruff`, `poetry`, `snow`, `orbctl`

## Zinit

[Zinit](https://github.com/zdharma-continuum/zinit) is the ZSH plugin manager used here. It handles binary installation from GitHub Releases, lazy-loaded plugins, and snippet-based completions.

### Initialization Flow

The Zinit block in `.zshrc` runs in this order:

1. **Bootstrap** — Clone Zinit into `$ZINIT_HOME` if absent, source `zinit.zsh`, prepend `$ZPFX/bin` to `PATH`.
2. **`z-a-bin-gem-node` annex** — Enables the `sbin` ice, which creates binary shims in `$ZPFX/bin` without modifying `PATH` directly.
3. **Binaries** — `fzf`, `bat`, and `starship` are fetched from GitHub Releases (`from"gh-r"`), shimmed via `sbin`, and configured via `atclone`/`atload`. `fzf` and `bat` use `wait lucid` for deferred loading; `starship` loads eagerly since the prompt depends on it.
4. **Plugins** — `fast-syntax-highlighting`, `zsh-autosuggestions`, `zsh-completions`, and `fzf-tab` load in a single deferred `for` block (`wait'1' lucid`). `zicompinit` is called via `atinit` on the first plugin — this is the recommended point to initialize the completion system after all plugins are registered.
5. **Local completions** — `_zinit_load_local_completions` registers each file in `$LOCAL_COMPS_DIR` as a `zinit snippet` with `as"completion"`. On first install (empty `$LOCAL_COMPS_DIR`), `update_zsh_completions` runs automatically, followed by a re-registration and `zicompinit` call so completions are available immediately without a second shell restart.

### Syntax Reference

`zinit ice` sets **ices** (modifiers) scoped to the immediately following `zinit` command. Key ices used here:

| Ice | Purpose |
| --- | ------- |
| `from"gh-r"` | Fetch from GitHub Releases instead of cloning |
| `as"null"` | Skip sourcing/binary treatment (used when `sbin` handles the binary) |
| `sbin"<glob>"` | Shim matched binary into `$ZPFX/bin` |
| `wait` / `wait"N"` | Defer loading post-prompt; `N` adds extra seconds |
| `lucid` | Suppress status output when using `wait` |
| `atclone"<cmd>"` | Run command after cloning |
| `atpull"%atclone"` | Re-run `atclone` command on `zinit update` |
| `atinit"<cmd>"` | Run command before sourcing the plugin |
| `atload"<cmd>"` | Run command after loading |
| `src"<file>"` | Source a file after loading |
| `completions` | Install completions found in the plugin |
| `blockf` | Block `fpath` modification (used when completions are managed manually) |
| `has"<cmd>"` | Conditionally load only if command exists in `PATH` |

Ice resolution order (observed): `atclone` → `atinit` → `pick` → `src` → `atload`. `atpull` runs independently on update (no `atinit`/`src`).

**Binary from GitHub Releases (`fzf`):**

```zsh
zinit ice wait lucid from"gh-r" as"null" sbin"fzf" \
    atclone"./fzf --zsh > init.zsh" \
    atpull"%atclone" \
    src"init.zsh" \
    atload"source ${CONFIG_DIR}/fzf/config.zsh"
zinit light junegunn/fzf
```

**Eager load with completions (`starship`):**

```zsh
zinit ice from"gh-r" sbin"starship" \
    atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
    atpull"%atclone" \
    atload"export STARSHIP_CONFIG=${CONFIG_DIR}/starship/starship.toml" \
    src"init.zsh"
zinit light starship/starship
```

No `wait` — loaded synchronously since the prompt depends on it. `_starship` completion is generated at clone time.

**Multi-plugin deferred block:**

```zsh
zinit wait'1' lucid light-mode for \
    atinit"ZINIT_COMPINIT_OPTS='-d ${ZSH_COMPDUMP}'; zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions \
    has"fzf" \
        Aloxaf/fzf-tab
```

The `for` syntax applies shared ices to all plugins and per-plugin ices to individual entries. `atinit` on `fast-syntax-highlighting` fires before it's sourced, making it the correct hook point for `zicompinit`.

**Local completions as snippets:**

`zinit snippet <path>` copies a local file into Zinit's cache without cloning a repo. The `as"completion"` ice installs it into `fpath`. Snippets are not auto-updated when the source changes — `update_zsh_completions` regenerates the files and calls `zinit update --snippets` to sync.

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
update_zsh_completions      # Regenerate completions for uv, uvx, ruff, poetry, snow, orbctl
```

Run this after updating tools that provide shell completions.

### Brewfile

```bash
brew bundle dump --file=~/dotfiles/Brewfile --force   # Export current packages
brew bundle install --file=~/dotfiles/Brewfile        # Install from Brewfile
brew bundle check --file=~/dotfiles/Brewfile          # Check what's missing
```

### Git Submodules

```bash
# Update all submodules to their latest versions
git submodule update --remote
git add .
git commit -m "Update all submodules to latest versions"

# Update only a specific submodule (e.g., tpm)
git submodule update --remote tmux/.tmux/plugins/tpm
git add .gitmodules tmux/.tmux/plugins/tpm
git commit -m "Update tpm to latest version"
```

## Adding Packages

1. `mkdir -p ~/dotfiles/nvim/.config/nvim`
2. Add config files mirroring `$HOME` structure
3. Add to `stow_packages()` in `install.sh`
4. `stow nvim`
