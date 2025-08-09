# === Unified Bash RC for non-NixOS environments (e.g., Git Bash, WSL) ===

# Source this file from ~/.bashrc

# History settings
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s histappend

# Aliases (kept in sync with home.nix and PowerShell profile)
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias gs='git status'
alias ga='git add'
alias gcom='git commit'
alias gp='git push'
alias gl='git log --oneline -10'
alias gd='git diff'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias grep='grep --color=auto'
alias which='command -v'
alias reload='source ~/.bashrc'

# Oh My Posh Initialization
# This assumes oh-my-posh is installed and on the PATH.
# The bootstrap script handles installing it on systems like Debian/Ubuntu.
if command -v oh-my-posh &> /dev/null; then
  eval "$(oh-my-posh init bash --config ~/.poshthemes/jandedobbeleer.omp.json)"
fi
