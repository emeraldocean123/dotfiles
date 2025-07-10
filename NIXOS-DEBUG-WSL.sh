#!/usr/bin/env bash
# NIXOS-DEBUG-WSL.sh - Diagnostic script for NixOS WSL dotfiles and Oh My Posh prompt

set -euo pipefail

echo "=== NixOS WSL Dotfiles & Oh My Posh Diagnostic ==="
echo "Date: $(date)"
echo "User: $(whoami)"
echo "Shell: $SHELL"
echo "Home: $HOME"
echo

echo "1. Checking symlinks in home directory:"
ls -l ~ | grep -E '\.bash(rc|_profile|_aliases)|\.gitconfig|\.poshthemes'
echo

echo "2. Checking if Oh My Posh is in PATH:"
if command -v oh-my-posh >/dev/null 2>&1; then
  echo "✔ oh-my-posh found at: $(command -v oh-my-posh)"
else
  echo "✖ oh-my-posh NOT found in PATH"
fi
echo

echo "3. Checking for theme file:"
if [ -f "$HOME/.poshthemes/jandedobbeleer.omp.json" ]; then
  echo "✔ Theme file exists: $HOME/.poshthemes/jandedobbeleer.omp.json"
else
  echo "✖ Theme file missing: $HOME/.poshthemes/jandedobbeleer.omp.json"
fi
echo

echo "4. Checking PATH variable:"
echo "$PATH"
echo

echo "5. Checking shell startup files for Oh My Posh logic:"
grep -E 'oh-my-posh|poshthemes' ~/.bashrc ~/.bash_profile 2>/dev/null || echo "No Oh My Posh logic found."
echo

echo "6. Checking nix-shell availability:"
if command -v nix-shell >/dev/null 2>&1; then
  echo "✔ nix-shell is available"
else
  echo "✖ nix-shell is NOT available"
fi
echo

echo "7. Checking for errors in .bashrc:"
bash -n ~/.bashrc && echo "✔ .bashrc syntax OK" || echo "✖ .bashrc has syntax errors"
echo

echo "=== End of diagnostics ==="
