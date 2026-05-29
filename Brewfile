# =============================================================================
# Brewfile - Full macOS development environment
# =============================================================================
# Used by: ./install.sh --full
# Works on: macOS only (includes casks and macOS-specific tools)
#
# This restores a complete Mac development environment including:
# - All dev tools from Brewfile.dev
# - Python version management (pyenv)
# - GUI applications (casks)
# - Fonts
# - VS Code extensions
# =============================================================================

# -----------------------------------------------------------------------------
# Import core dev tools
# -----------------------------------------------------------------------------
instance_eval(File.read("#{__dir__}/Brewfile.dev")) if File.exist?("#{__dir__}/Brewfile.dev")

# -----------------------------------------------------------------------------
# Taps (third-party repositories)
# -----------------------------------------------------------------------------
tap "jesseduffield/lazydocker"
brew "lazydocker"           # Docker TUI

# -----------------------------------------------------------------------------
# Python version management (macOS only)
# -----------------------------------------------------------------------------
brew "pyenv"
brew "pyenv-virtualenv"

# -----------------------------------------------------------------------------
# Node version management (macOS only)
# -----------------------------------------------------------------------------
brew "fnm"

# -----------------------------------------------------------------------------
# Languages & runtimes
# -----------------------------------------------------------------------------
brew "node"
brew "rust"

# -----------------------------------------------------------------------------
# Build tools & libraries
# -----------------------------------------------------------------------------
brew "boost"
brew "bzip2"
brew "cmake"
brew "glib"
brew "krb5"
brew "libssh2"
brew "llvm@14"
brew "tcl-tk"
brew "zlib"

# -----------------------------------------------------------------------------
# CLI applications
# -----------------------------------------------------------------------------
brew "duck"                 # Cyberduck CLI
brew "imagemagick"          # Image manipulation
brew "llmfit"               # Find right-sized LLMs that fit this machine
brew "lolcat"               # Rainbow text
brew "pillow"               # Python imaging
brew "pipx"                 # Python app installer
brew "uv"                   # Fast Python package and project manager
brew "tmux"                 # Terminal multiplexer

# -----------------------------------------------------------------------------
# Databases
# -----------------------------------------------------------------------------
brew "postgresql@14"

# -----------------------------------------------------------------------------
# GUI Applications (Casks)
# -----------------------------------------------------------------------------
cask "orbstack"                    # Docker & Linux VMs
cask "font-hack-nerd-font"         # Nerd Font for terminal
cask "font-roboto-mono-nerd-font"  # Nerd Font used by Alacritty

