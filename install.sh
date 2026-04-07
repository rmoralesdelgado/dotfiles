#!/usr/bin/env bash
#
# Dotfiles Bootstrap Script
# Installs dependencies and stows dotfiles packages
#
# Usage:
#   ./install.sh          # Minimal: install stow, stow packages
#   ./install.sh --dev    # Dev environment: core CLI tools via Brewfile.dev
#   ./install.sh --full   # Full Mac restore: all tools, apps, fonts via Brewfile
#   ./install.sh --unstow # Remove all symlinks
#

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

# =============================================================================
# Configuration
# =============================================================================

# Brewfile locations
BREWFILE_DEV="$DOTFILES_DIR/Brewfile.dev"   # Core CLI tools for dev environments
BREWFILE_FULL="$DOTFILES_DIR/Brewfile"      # Full Mac restoration

# =============================================================================
# Output Helpers
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# =============================================================================
# Platform Detection
# =============================================================================

detect_platform() {
    case "$OSTYPE" in
        darwin*)  echo "macos" ;;
        linux*)   echo "linux" ;;
        *)        echo "unknown" ;;
    esac
}

PLATFORM=$(detect_platform)

# =============================================================================
# Package Manager Functions
# =============================================================================

# Install Homebrew if not present
ensure_homebrew() {
    if command -v brew &>/dev/null; then
        info "Homebrew already installed"
        return 0
    fi

    # On macOS, the Homebrew installer requires admin rights. Check early to
    # give a clear error instead of letting the installer fail cryptically.
    if [[ "$PLATFORM" == "macos" ]] && ! id -Gn | grep -qw "admin"; then
        error "Homebrew requires your account to be an Administrator.\n\
  The shell installer will fail without admin rights. Instead, install\n\
  Homebrew manually using the .pkg installer, then re-run this script:\n\
  https://github.com/Homebrew/brew/releases"
    fi

    info "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to PATH for this session
    if [[ "$PLATFORM" == "macos" ]]; then
        if [[ -x "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -x "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    elif [[ "$PLATFORM" == "linux" ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi

    # Verify installation
    if ! command -v brew &>/dev/null; then
        error "Homebrew installation failed"
    fi
    info "Homebrew installed successfully"
}

# Install stow via native package manager (minimal mode)
install_stow_native() {
    if command -v stow &>/dev/null; then
        info "GNU Stow already installed"
        return 0
    fi

    info "Installing GNU Stow..."
    case "$PLATFORM" in
        macos)
            if command -v brew &>/dev/null; then
                brew install stow
            else
                error "Homebrew not found. Run with --full to install Homebrew, or install it manually: https://brew.sh"
            fi
            ;;
        linux)
            if command -v apt-get &>/dev/null; then
                sudo apt-get update && sudo apt-get install -y stow
            elif command -v dnf &>/dev/null; then
                sudo dnf install -y stow
            elif command -v pacman &>/dev/null; then
                sudo pacman -S --noconfirm stow
            elif command -v apk &>/dev/null; then
                sudo apk add stow
            else
                error "Could not detect package manager. Please install stow manually or run with --full."
            fi
            ;;
        *)
            error "Unknown platform. Please install stow manually."
            ;;
    esac
}

# =============================================================================
# Dependency Installation
# =============================================================================

# Install from a Brewfile
install_from_brewfile() {
    local brewfile="$1"
    local name="$2"

    if [[ ! -f "$brewfile" ]]; then
        error "Brewfile not found: $brewfile"
    fi

    info "Installing packages from $name..."
    brew bundle install --file="$brewfile"
    info "Packages from $name installed successfully"
}


# Create required directories
create_directories() {
    info "Creating required directories..."
    # Source zshenv to get canonical directory paths (single source of truth)
    # shellcheck source=zsh/.zshenv
    source "$DOTFILES_DIR/zsh/.zshenv"
    mkdir -p "$LOCAL_BIN_DIR"
    mkdir -p "$ZINIT_DIR"
    mkdir -p "$LOCAL_COMPS_DIR"
    mkdir -p "$CONFIG_DIR"
}

# Initialize git submodules (e.g., tpm for tmux)
init_git_submodules() {
    if ! command -v git &>/dev/null; then
        warn "git not found - skipping submodule initialization"
        return 0
    fi

    info "Initializing git submodules..."
    git submodule update --init --recursive
    info "Git submodules initialized"
}

# Backup existing files that would conflict with stow
# Takes package name as argument (e.g., "zsh")
backup_existing() {
    local pkg="${1:-zsh}"
    local pkg_dir="$DOTFILES_DIR/$pkg"
    local backup_dir="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
    local needs_backup=false
    
    # Check if package directory exists
    if [[ ! -d "$pkg_dir" ]]; then
        warn "Package directory '$pkg' not found"
        return 1
    fi
    
    # Get all files and directories at root level of the package
    # These mirror the structure that will be symlinked to $HOME
    for item in "$pkg_dir"/.[!.]* "$pkg_dir"/*; do
        # Skip if glob didn't match anything
        [[ -e "$item" ]] || continue
        
        # Get the basename (e.g., ".zshrc" or ".config")
        local basename="${item##*/}"
        local target="$HOME/$basename"
        
        # Check if target exists and is NOT a symlink
        if [[ -e "$target" && ! -L "$target" ]]; then
            needs_backup=true
            break
        fi
    done
    
    if $needs_backup; then
        info "Backing up existing files to $backup_dir"
        mkdir -p "$backup_dir"
        
        # Move each conflicting file/directory to backup
        for item in "$pkg_dir"/.[!.]* "$pkg_dir"/*; do
            [[ -e "$item" ]] || continue
            
            local basename="${item##*/}"
            local target="$HOME/$basename"
            
            # Only backup if it exists and is not a symlink
            if [[ -e "$target" && ! -L "$target" ]]; then
                info "  Backing up: $basename"
                mv "$target" "$backup_dir/"
            fi
        done
    fi
}

# Stow a single package (backup first, then stow)
stow_package() {
    local pkg="$1"
    
    if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
        backup_existing "$pkg"
        info "Stowing $pkg..."
        stow -v --target="$HOME" "$pkg"
    else
        warn "Package '$pkg' not found, skipping"
    fi
}

# Stow all packages
stow_packages() {
    info "Stowing dotfiles packages..."
    cd "$DOTFILES_DIR"
    
    # Stow each package directory
    stow_package "zsh"
    stow_package "git"
    
    # Add more packages here as needed
    # stow_package "nvim"
}

# =============================================================================
# Main Functions
# =============================================================================

main() {
    local mode="${1:-minimal}"
    local label

    case "$mode" in
        minimal) label="Minimal" ;;
        dev)     label="Dev" ;;
        full)    label="Full Mac Setup" ;;
    esac

    _completed=false
    trap '[[ "$_completed" == false ]] && warn "Installation did not complete — some steps (e.g. stow) may not have run. Check the output above."' EXIT

    echo ""
    echo "=================================="
    echo "  Dotfiles Installation ($label)"
    echo "=================================="
    echo ""
    info "Detected platform: $PLATFORM"
    echo ""

    case "$mode" in
        minimal)
            info "Minimal mode: installing stow only..."
            install_stow_native
            if ! command -v eza &>/dev/null; then
                warn "eza not found - ls aliases will not work. Run with --dev or --full to install."
            fi
            if ! command -v git &>/dev/null; then
                warn "git not found - Zinit will not work. Please install git."
            fi
            ;;
        dev)
            info "Installing dev environment dependencies..."
            ensure_homebrew
            install_from_brewfile "$BREWFILE_DEV" "Brewfile.dev"
            ;;
        full)
            info "Installing full Mac environment..."
            if [[ "$PLATFORM" != "macos" ]]; then
                warn "Full installation is intended for macOS. Some packages may not install on Linux."
            fi
            ensure_homebrew
            install_from_brewfile "$BREWFILE_FULL" "Brewfile"
            ;;
    esac

    create_directories
    init_git_submodules
    stow_packages

    _completed=true
    echo ""
    info "$label installation complete!"
    info "Please restart your shell or run: exec zsh"
    if [[ "$mode" == "minimal" ]]; then
        info "Run with --dev for dev tools or --full for complete Mac setup."
    fi
    echo ""
}

# Unstow all packages
main_unstow() {
    info "Detected platform: $PLATFORM"
    info "Unstowing all packages..."
    cd "$DOTFILES_DIR"
    for pkg in */; do
        pkg="${pkg%/}"
        [[ -d "$pkg" ]] && stow -v --target="$HOME" -D "$pkg"
    done
    info "Unstow complete"
}

# Show help
show_help() {
    echo "Dotfiles Bootstrap Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  (no args)      Minimal: install stow only, then symlink packages"
    echo "  --dev          Dev environment: Homebrew + core CLI tools (Brewfile.dev)"
    echo "  --full         Full Mac restore: all tools, apps, fonts, extensions (Brewfile)"
    echo "  --list         List packages for each installation mode"
    echo "  --unstow       Remove all symlinks (unstow all packages)"
    echo "  --help, -h     Show this help message"
    echo ""
    echo "Brewfiles:"
    echo "  Brewfile.dev   Core CLI tools for devcontainers/VMs"
    echo "  Brewfile       Complete Mac environment (imports Brewfile.dev)"
    echo ""
}

# List packages for each mode
show_list() {
    echo "Dotfiles Package List"
    echo ""
    echo "Detected platform: $PLATFORM"
    echo ""

    echo "=== Minimal Mode (default) ==="
    echo "  Installed via native package manager:"
    echo "    - stow"
    echo ""

    echo "=== Dev Mode (--dev) ==="
    echo "  Source: Brewfile.dev"
    echo "  Packages:"
    if [[ -f "$BREWFILE_DEV" ]]; then
        grep -E '^brew "' "$BREWFILE_DEV" | sed 's/brew "\([^"]*\)".*/    - \1/'
    else
        echo "    (Brewfile.dev not found)"
    fi
    echo ""

    echo "=== Full Mode (--full) ==="
    echo "  Source: Brewfile (imports Brewfile.dev)"
    echo ""
    if [[ -f "$BREWFILE_FULL" ]]; then
        echo "  Formulae (brew):"
        grep -E '^brew "' "$BREWFILE_FULL" | sed 's/brew "\([^"]*\)".*/    - \1/'
        echo ""
        echo "  Casks (GUI apps):"
        grep -E '^cask "' "$BREWFILE_FULL" | sed 's/cask "\([^"]*\)".*/    - \1/'
    else
        echo "    (Brewfile not found)"
    fi
    echo ""
}

# =============================================================================
# CLI Entry Point
# =============================================================================

case "${1:-}" in
    --help|-h) show_help    ;;
    --list)    show_list    ;;
    --dev)     main dev     ;;
    --full)    main full    ;;
    --unstow)  main_unstow  ;;
    *)         main minimal ;;
esac
