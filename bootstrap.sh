#!/usr/bin/env bash

# Exit immediately if a command fails
set -e

echo "🔧 Starting cross-platform bootstrap setup..."

# ----------------------------------------
# 1. Detect OS and set package install command
# ----------------------------------------
echo "🧠 Detecting operating system..."

if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        debian|ubuntu)
            echo "📦 Detected Debian-based system"
            INSTALL_CMD="sudo apt update && sudo apt install -y"
            ;;
        nixos)
            echo "📦 Detected NixOS"
            INSTALL_CMD="nix-env -iA nixpkgs"
            ;;
        arch)
            echo "📦 Detected Arch Linux"
            INSTALL_CMD="sudo pacman -Sy --noconfirm"
            ;;
        *)
            echo "❌ Unsupported distro: $ID"
            exit 1
            ;;
    esac
else
    echo "❌ Cannot detect OS. Aborting."
    exit 1
fi

# ----------------------------------------
# 2. Install essential packages
# ----------------------------------------
echo "📦 Installing essential packages..."
$INSTALL_CMD git curl wget unzip nano

# ----------------------------------------
# 3. Clone dotfiles repository
# ----------------------------------------
echo "📁 Cloning dotfiles repository..."
DOTFILES_DIR="$HOME/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    git clone https://github.com/emeraldocean123/dotfiles.git "$DOTFILES_DIR"
else
    echo "✅ Dotfiles already cloned."
fi

# ----------------------------------------
# 4. Link .bash_aliases from dotfiles
# ----------------------------------------
echo "🔗 Linking .bash_aliases..."
ln -sf "$DOTFILES_DIR/bash_aliases" "$HOME/.bash_aliases"

# ----------------------------------------
# 5. Install Oh My Posh
# ----------------------------------------
echo "🎨 Installing Oh My Posh..."
mkdir -p "$HOME/.local/bin"
curl -s https://api.github.com/repos/JanDeDobbeleer/oh-my-posh/releases/latest \
| grep "browser_download_url.*linux-amd64" \
| cut -d '"' -f 4 \
| wget -i - -O "$HOME/.local/bin/oh-my-posh"
chmod +x "$HOME/.local/bin/oh-my-posh"

# ----------------------------------------
# 6. Download Oh My Posh theme
# ----------------------------------------
echo "🎨 Downloading theme..."
mkdir -p "$HOME/.poshthemes"
curl -o "$HOME/.poshthemes/jandedobbeleer.omp.json" \
  https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/jandedobbeleer.omp.json

# ----------------------------------------
# 7. Update .bashrc with configuration
# ----------------------------------------
echo "📝 Updating .bashrc..."
BASHRC="$HOME/.bashrc"

if ! grep -q "oh-my-posh init bash" "$BASHRC"; then
cat << 'EOF' >> "$BASHRC"

# ----------------------------------------
# Custom shell configuration
# ----------------------------------------

# Add user's local bin directory to PATH so custom tools like oh-my-posh are found
export PATH="$HOME/.local/bin:$PATH"

# Source aliases from ~/.bash_aliases if the file exists
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Initialize Oh My Posh with the jandedobbeleer theme
eval "$($HOME/.local/bin/oh-my-posh init bash --config ~/.poshthemes/jandedobbeleer.omp.json)"
EOF
fi

# ----------------------------------------
# 8. Reload shell
# ----------------------------------------
echo "✅ Bootstrap complete. Reloading shell..."
exec bash
