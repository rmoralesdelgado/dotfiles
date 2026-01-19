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
tap "qmk/qmk"
tap "osx-cross/arm"
tap "osx-cross/avr"

# -----------------------------------------------------------------------------
# Python version management (macOS only)
# -----------------------------------------------------------------------------
brew "pyenv"
brew "pyenv-virtualenv"

# -----------------------------------------------------------------------------
# Languages & runtimes
# -----------------------------------------------------------------------------
brew "node"
brew "rust"
brew "python@3.9"
brew "python@3.10"

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
brew "lolcat"               # Rainbow text
brew "neofetch"             # System info display
brew "pillow"               # Python imaging
brew "pipx"                 # Python app installer
brew "tmux"                 # Terminal multiplexer

# -----------------------------------------------------------------------------
# Databases
# -----------------------------------------------------------------------------
brew "postgresql@14"

# -----------------------------------------------------------------------------
# Keyboard/hardware tools
# -----------------------------------------------------------------------------
brew "qmk/qmk/qmk"          # QMK firmware tools

# -----------------------------------------------------------------------------
# GUI Applications (Casks)
# -----------------------------------------------------------------------------
cask "orbstack"             # Docker & Linux VMs
cask "font-hack-nerd-font"  # Nerd Font for terminal

# -----------------------------------------------------------------------------
# VS Code Extensions
# -----------------------------------------------------------------------------
# Python
vscode "ms-python.python"
vscode "ms-python.vscode-pylance"
vscode "ms-python.debugpy"
vscode "ms-python.black-formatter"
vscode "ms-python.isort"
vscode "ms-python.vscode-python-envs"
vscode "charliermarsh.ruff"

# Jupyter
vscode "ms-toolsai.jupyter"
vscode "ms-toolsai.jupyter-keymap"
vscode "ms-toolsai.jupyter-renderers"
vscode "ms-toolsai.vscode-jupyter-cell-tags"
vscode "ms-toolsai.vscode-jupyter-slideshow"

# Remote development
vscode "ms-vscode-remote.remote-containers"
vscode "ms-vscode-remote.remote-ssh"
vscode "ms-vscode-remote.remote-ssh-edit"
vscode "ms-vscode.remote-explorer"
vscode "ms-vscode.remote-server"
vscode "ms-azuretools.vscode-containers"
vscode "ms-azuretools.vscode-docker"
vscode "docker.docker"

# Data & databases
vscode "mechatroner.rainbow-csv"
vscode "snowflake.snowflake-vsc"
vscode "bastienboutonnet.vscode-dbt"

# Themes & UI
vscode "dracula-theme.theme-dracula"
vscode "teabyii.ayu"
vscode "vscode-icons-team.vscode-icons"

# Git
vscode "mhutchie.git-graph"

# Languages & templates
vscode "samuelcolvin.jinjahtml"
vscode "wholroyd.jinja"
vscode "tamasfe.even-better-toml"
vscode "editorconfig.editorconfig"

# AI
vscode "saoudrizwan.claude-dev"
