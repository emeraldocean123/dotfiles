# === Unified Bash RC for non-NixOS environments (e.g., Git Bash, WSL) ===

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

# --- Git Bash on Windows Fix ---
# Manually add the default Windows location for oh-my-posh to the PATH
# so that Git Bash can find and execute it.
if [[ "$OSTYPE" == "msys"* ]]; then
  OMP_WINDOWS_PATH="/c/Users/$USER/AppData/Local/Programs/oh-my-posh/bin"
  if [ -d "$OMP_WINDOWS_PATH" ] && [[ ":$PATH:" != *":$OMP_WINDOWS_PATH:"* ]]; then
    export PATH="$PATH:$OMP_WINDOWS_PATH"
  fi
fi
# -----------------------------

# Oh My Posh Initialization
if command -v oh-my-posh &> /dev/null; then
  eval "$(oh-my-posh init bash --config ~/.poshthemes/jandedobbeleer.omp.json)"
fi

# Zoxide Initialization (if installed)
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init bash)"
fi
