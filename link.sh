#!/bin/bash

# 🔗 Joseph's Dotfiles Linking Script
# This script creates symlinks for all configuration files

set -e  # Exit on any error

DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

echo "🧬 Linking Joseph's dotfiles..."

# Check if dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "❌ Dotfiles directory not found at $DOTFILES_DIR"
    echo "🔄 Please clone the repository first or run bootstrap.sh"
    exit 1
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"
echo "📁 Created backup directory: $BACKUP_DIR"

# Function to create symlink with backup
link_file() {
    local source="$DOTFILES_DIR/$1"
    local target="$HOME/$2"
    
    if [ ! -f "$source" ]; then
        echo "⚠️  Source file not found: $source (skipping)"
        return 0
    fi
    
    if [ -f "$target" ] || [ -L "$target" ]; then
        echo "📋 Backing up existing $target"
        mv "$target" "$BACKUP_DIR/$(basename "$target")"
    fi
    
    echo "🔗 Linking $source -> $target"
    ln -sf "$source" "$target"
}

# Function to create directory symlink with backup
link_dir() {
    local source="$DOTFILES_DIR/$1"
    local target="$HOME/$2"
    
    if [ ! -d "$source" ]; then
        echo "⚠️  Source directory not found: $source (skipping)"
        return 0
    fi
    
    if [ -d "$target" ] || [ -L "$target" ]; then
        echo "📋 Backing up existing $target"
        mv "$target" "$BACKUP_DIR/$(basename "$target")"
    fi