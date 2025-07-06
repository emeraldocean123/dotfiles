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

# Enable color support
if [ -x /usr/bin/dircolors ]; then
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

# Useful aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# fzf functions
ff() { find . -type f | fzf; }
fd() { find . -type d | fzf | xargs -r cd; }

# Source Nix profile
if [ -e /home/joseph/.nix-profile/etc/profile.d/nix.sh ]; then 
    . /home/joseph/.nix-profile/etc/profile.d/nix.sh
fi
