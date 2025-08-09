#!/usr/bin/env bash
# Final, robust bootstrap script for Bash environments.

set -e

# Define the absolute path to the real bashrc within the dotfiles repo
BASHRC_SOURCE_PATH="$HOME/Documents/dotfiles/bashrc"
# Define the path for the loader file in the user's home directory
BASHRC_TARGET_PATH="$HOME/.bashrc"

echo "Creating a loader file at $BASHRC_TARGET_PATH..."

# Create a simple file that does nothing but `source` the repository's bashrc.
# This is more reliable than symlinks in some Windows environments.
echo "# This is a loader file. Do not edit it directly." > "$BASHRC_TARGET_PATH"
echo "# Your actual configuration is in: $BASHRC_SOURCE_PATH" >> "$BASHRC_TARGET_PATH"
echo "if [ -f \"$BASHRC_SOURCE_PATH\" ]; then source \"$BASHRC_SOURCE_PATH\"; fi" >> "$BASHRC_TARGET_PATH"

echo "✅ Done. Please restart your shell or run 'source ~/.bashrc'."
