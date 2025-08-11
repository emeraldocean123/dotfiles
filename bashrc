# === Unified Bash RC for non-NixOS environments (e.g., Git Bash, WSL) ===

# Configuration
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/Documents/dotfiles}"

# History settings
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s histappend

# Aliases
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

# --- Git Bash on Windows PATH Fixes ---
if [[ "$OSTYPE" == "msys"* ]]; then
  # Add Oh My Posh path
  OMP_WINDOWS_PATH="/c/Users/$USER/AppData/Local/Programs/oh-my-posh/bin"
  if [ -d "$OMP_WINDOWS_PATH" ] && [[ ":$PATH:" != *":$OMP_WINDOWS_PATH:"* ]]; then
    export PATH="$PATH:$OMP_WINDOWS_PATH"
  fi
  # Add general WinGet binaries path (for fastfetch, etc.)
  WINGET_BIN_PATH="/c/Users/$USER/AppData/Local/Microsoft/WinGet/bin"
  if [ -d "$WINGET_BIN_PATH" ] && [[ ":$PATH:" != *":$WINGET_BIN_PATH:"* ]]; then
    export PATH="$PATH:$WINGET_BIN_PATH"
  fi
fi

# --- Run fastfetch on startup (once per session) ---
if [ -z "$__FASTFETCH_SHOWN" ] && [ -n "$PS1" ]; then
  if command -v fastfetch &>/dev/null; then
    fastfetch --logo-width 30
    export __FASTFETCH_SHOWN=1
  fi
fi

# --- Oh My Posh Initialization (using configurable path) ---
if command -v oh-my-posh &> /dev/null; then
  THEME_PATH="$DOTFILES_DIR/posh-themes/jandedobbeleer.omp.json"
  if [ -f "$THEME_PATH" ]; then
    eval "$(oh-my-posh init bash --config "$THEME_PATH")"
  fi
fi
