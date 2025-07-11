#!/bin/bash
# /home/joseph/dotfiles/bashrc: executed by bash for non-login shells.
# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History settings
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s histappend
shopt -s checkwinsize

# Add user's local bin to PATH for tools like oh-my-posh (avoid duplicates)
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Enable color support
if [ -x /usr/bin/dircolors ]; then
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

# Source bash aliases if available
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Useful aliases (built-in, only if not overridden)
alias la='ls -A'
alias l='ls -CF'

# fzf functions
ff() { find . -type f | fzf; }
fd() { find . -type d | fzf | xargs -r cd; }

# Oh My Posh prompt
# Persistent Oh My Posh prompt for NixOS/WSL
if ! command -v oh-my-posh >/dev/null 2>&1; then
  if command -v nix-shell >/dev/null 2>&1; then
    # Add oh-my-posh to PATH if not already available
    OMP_PATH=$(nix-shell -p oh-my-posh --run 'dirname $(which oh-my-posh)' 2>/dev/null)
    if [ -n "$OMP_PATH" ] && [[ ":$PATH:" != *":$OMP_PATH:"* ]]; then
      export PATH="$PATH:$OMP_PATH"
    fi
  fi
fi

# Initialize Oh My Posh if available and theme exists
if command -v oh-my-posh >/dev/null 2>&1; then
  if [ -f "$HOME/.poshthemes/jandedobbeleer.omp.json" ]; then
    eval "$(oh-my-posh init bash --config $HOME/.poshthemes/jandedobbeleer.omp.json 2>/dev/null)"
  elif [ -f "~/.poshthemes/jandedobbeleer.omp.json" ]; then
    eval "$(oh-my-posh init bash --config ~/.poshthemes/jandedobbeleer.omp.json 2>/dev/null)"
  fi
fi

# SSH agent auto-start
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_debian >/dev/null 2>&1
