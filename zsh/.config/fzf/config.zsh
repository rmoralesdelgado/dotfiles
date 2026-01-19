#! /usr/bin/env zsh

# CONFIG FILE FOR FZF

# Sourced by Zinit upon loading of FZF


# Fix alt + C binding; originally -> ç
bindkey "ç" fzf-cd-widget

# Set defaults
# Dracula theme for FZF from https://draculatheme.com/fzf
export FZF_DEFAULT_OPTS="\
    --layout=reverse --border=rounded --preview-window=border-rounded \
    --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 \
    --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 \
    --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 \
    --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4"

# Preview file content using bat
export FZF_CTRL_T_OPTS="\
    --walker-skip .git,node_modules,target \
    --preview 'bat -n --color=always {}' \
    --bind 'ctrl-/:change-preview-window(down|hidden|)' \
    --border-label=' fuzzy find '"
# Print tree structure in the preview window
export FZF_ALT_C_OPTS="\
    --walker-skip .git,node_modules,target \
    --preview 'eza --icons=always --tree --color=always {}' \
    --border-label=' change directory '"
