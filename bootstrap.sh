#!/usr/bin/env bash
# Final, robust bootstrap script using COPY instead of symlinks.

set -e
DOTFILES_DIR_PATH="$HOME/Documents/dotfiles"
BASHRC_SOURCE_PATH="$DOTFILES_DIR_PATH/bashrc"
BASHRC_TARGET_PATH="$HOME/.bashrc"
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

echo "Setting up Bash environment from $DOTFILES_DIR_PATH..."
mkdir -p "$BACKUP_DIR"

# Backup the old file if it exists
if [ -f "$BASHRC_TARGET_PATH" ]; then
    echo "Backing up existing $BASHRC_TARGET_PATH..."
    mv "$BASHRC_TARGET_PATH" "$BACKUP_DIR/"
fi

# Copy the new bashrc file. This is more reliable than symlinks in Git Bash.
echo "Copying $BASHRC_SOURCE_PATH -> $BASHRC_TARGET_PATH..."
cp "$BASHRC_SOURCE_PATH" "$BASHRC_TARGET_PATH"

echo "✅ Done. Please restart your shell."
