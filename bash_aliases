#!/bin/bash
# Joseph's Cross-Platform Shell Aliases
# These aliases work consistently across PowerShell, Bash, and Zsh

# Directory listing (matches PowerShell ll, la, ls functions)
alias ll='ls -lah --color=auto'
alias la='ls -lah --color=auto'
alias l='ls -lh --color=auto'

# Git aliases (matches PowerShell git functions)
alias gs='git status'
alias ga='git add'
alias gcom='git commit'
alias gp='git push'
alias gl='git log --oneline -10'
alias gd='git diff'

# Navigation (matches PowerShell navigation)
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Utility aliases
alias grep='grep --color=auto'
alias which='command -v'
alias reload='source ~/.bashrc'
