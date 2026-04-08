#! /usr/bin/env zsh
#### ZSHENV
#### Made by Raul Morales Delgado


#### ENVIRONMENT

## GENERAL EXPORTS

export DOTFILES_REPO="rmoralesdelgado/dotfiles"

export CONFIG_DIR="${HOME}/.config"        # Config files
export INSTALLS_DIR="${HOME}/.installs"    # Install scripts
export LOCAL_BIN_DIR="${HOME}/.local/bin"  # Local binaries
export LOCAL_COMPS_DIR="${HOME}/.zfunc"    # Manual completions
export ZSH_COMPDUMP="${HOME}/.zcompdump"   # Completion cache

export ZINIT_DIR="${HOME}/.local/share/zinit"
export ZINIT_HOME="${ZINIT_DIR}/zinit.git"

## UV

export UV_PYTHON_PREFERENCE="${UV_PYTHON_PREFERENCE:-only-managed}"
export UV_PYTHON_DOWNLOADS="${UV_PYTHON_DOWNLOADS:-automatic}"