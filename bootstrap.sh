#!/usr/bin/env bash
# Simplified bootstrap script for Bash environments (Git Bash, WSL, etc.)

set -e
# Find the directory where the script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

echo "Setting up Bash environment from $DOTFILES_DIR..."
mkdir -p "$BACKUP_DIR"

# Function to create a symlink with a backup of the original file
link_with_backup() {
    local source="$1"
    local target="$2"
    if [ -e "$target" ]; then
        if [ ! -L "$target" ]; then
            echo "Backing up existing $target to $BACKUP_DIR"
            mv "$target" "$BACKUP_DIR/"
        else
            # If it's already a symlink, just remove it
            rm "$target"
        fi
    fi
    echo "Linking $source -> $target"
    ln -s "$source" "$target"
}

# Link the unified bashrc and the theme directory
link_with_backup "$DOTFILES_DIR/bashrc" "$HOME/.bashrc"
link_with_backup "$DOTFILES_DIR/posh-themes" "$HOME/.poshthemes"

echo "✅ Done. Please restart your shell or run 'source ~/.bashrc'."
