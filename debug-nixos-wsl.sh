#!/bin/bash
# Debug script to check dotfiles setup in NixOS WSL

echo "🔍 NixOS WSL Dotfiles Debug Report"
echo "=================================="
echo

echo "📁 Current shell and environment:"
echo "SHELL: $SHELL"
echo "HOME: $HOME"
echo "PWD: $PWD"
echo

echo "🔗 Checking symlinks:"
ls -la ~/.bashrc ~/.bash_profile ~/.bash_aliases ~/.gitconfig ~/.poshthemes 2>/dev/null || echo "Some files missing"
echo

echo "📂 Checking if dotfiles directory exists:"
ls -la ~/dotfiles/ 2>/dev/null || echo "dotfiles directory not found"
echo

echo "🎨 Checking Oh My Posh availability:"
command -v oh-my-posh >/dev/null 2>&1 && echo "✅ oh-my-posh found: $(which oh-my-posh)" || echo "❌ oh-my-posh not found"
echo

echo "🛠️ Checking nix-shell availability:"
command -v nix-shell >/dev/null 2>&1 && echo "✅ nix-shell found: $(which nix-shell)" || echo "❌ nix-shell not found"
echo

echo "🎯 Checking theme file:"
if [ -f "$HOME/.poshthemes/jandedobbeleer.omp.json" ]; then
    echo "✅ Theme file exists"
else
    echo "❌ Theme file missing: $HOME/.poshthemes/jandedobbeleer.omp.json"
fi
echo

echo "🔄 Testing Oh My Posh PATH setup:"
if ! command -v oh-my-posh >/dev/null 2>&1; then
    if command -v nix-shell >/dev/null 2>&1; then
        echo "⏳ Trying to add oh-my-posh to PATH via nix-shell..."
        export PATH="$PATH:$(nix-shell -p oh-my-posh --run 'dirname $(which oh-my-posh)')"
        command -v oh-my-posh >/dev/null 2>&1 && echo "✅ oh-my-posh now available" || echo "❌ Failed to make oh-my-posh available"
    else
        echo "❌ Cannot test - nix-shell not available"
    fi
else
    echo "✅ oh-my-posh already available"
fi
echo

echo "📋 Current aliases:"
alias | grep -E "(ll|la|gs)" || echo "No expected aliases found"
echo

echo "🎨 Current prompt (PS1):"
echo "PS1='$PS1'"
echo

echo "🔚 Debug complete. Run this script in your NixOS WSL to diagnose issues."
