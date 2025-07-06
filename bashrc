# ~/.bashrc: executed by bash for non-login shells.

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
if command -v oh-my-posh &> /dev/null && [ -f ~/.poshthemes/jandedobbeleer.omp.json ]; then
    eval "$(oh-my-posh init bash --config ~/.poshthemes/jandedobbeleer.omp.json)"
fi