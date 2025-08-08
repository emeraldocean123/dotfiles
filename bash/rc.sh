# === Unified Bash RC (Git Bash / WSL / Linux / macOS) ===

# Resolve DOTFILES
if [ -z "${DOTFILES:-}" ]; then
  if command -v cmd.exe >/dev/null 2>&1; then
    DOTFILES="$HOME/Documents/dotfiles"
  else
    DOTFILES="$HOME/dotfiles"
  fi
fi
export DOTFILES

# Fastfetch (optional)
if command -v fastfetch >/dev/null 2>&1; then
  fastfetch || true
fi

# Oh My Posh prompt
# Add typical winget path when on Windows Git Bash/MSYS
case "$OSTYPE" in
  msys*|cygwin*)
    if [ -n "${LOCALAPPDATA:-}" ]; then
      OMP_WIN="$LOCALAPPDATA/Programs/oh-my-posh/bin"
      if [ -d "$OMP_WIN" ] && [[ ":$PATH:" != *":$OMP_WIN:"* ]]; then
        PATH="$PATH:$OMP_WIN"
      fi
    fi
  ;;
esac

THEME="$DOTFILES/posh-themes/jandedobbeleer.omp.json"
if command -v oh-my-posh >/dev/null 2>&1; then
  if [ -f "$THEME" ]; then
    eval "$(oh-my-posh init bash --config "$THEME")"
  else
    eval "$(oh-my-posh init bash)"
  fi
fi

# Friendly git helpers
alias gs='git status'
alias gl='git --no-pager log --oneline -n 20'
alias gd='git --no-pager diff'
