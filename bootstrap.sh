#!/usr/bin/env bash

# 🚀 Joseph's Unified Dotfiles Bootstrap Script
# This script installs dependencies AND links all configuration files

set -e  # Exit on any error

echo "🔧 Starting cross-platform bootstrap setup..."

# ----------------------------------------
# 1. Detect OS and set package install command
# ----------------------------------------
echo "🧠 Detecting operating system..."

DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# Check if we're in Windows/WSL environment
if [[ -n "$WSL_DISTRO_NAME" ]]; then
    echo "🪟 Running in WSL: $WSL_DISTRO_NAME"
    IS_WSL="true"
else
    IS_WSL="false"
fi

# Check for PowerShell availability (Windows or cross-platform PowerShell)
if command -v pwsh &> /dev/null || command -v powershell &> /dev/null; then
    POWERSHELL_AVAILABLE="true"
    if command -v pwsh &> /dev/null; then
        POWERSHELL_CMD="pwsh"
    else
        POWERSHELL_CMD="powershell"
    fi
    echo "💙 PowerShell detected: $POWERSHELL_CMD"
else
    POWERSHELL_AVAILABLE="false"
fi

if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        debian|ubuntu)
            echo "📦 Detected Debian-based system"
            NONFREE_INSTALL="true"
            ;;
        nixos)
            echo "📦 Detected NixOS"
            NONFREE_INSTALL="false"  # NixOS handles packages differently
            ;;
        arch)
            echo "📦 Detected Arch Linux" 
            NONFREE_INSTALL="true"
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
# 2. Install essential packages (skip on NixOS)
# ----------------------------------------
if [ "$NONFREE_INSTALL" = "true" ]; then
    echo "📦 Installing essential packages..."
    case "$ID" in
        debian|ubuntu)
            sudo apt update
            sudo apt install -y git curl wget unzip nano
            ;;
        arch)
            sudo pacman -Sy --noconfirm git curl wget unzip nano
            ;;
    esac
else
    echo "📦 Skipping package installation on NixOS (use flake.nix instead)"
fi

# ----------------------------------------
# 3. Clone or update dotfiles repository
# ----------------------------------------
echo "📁 Setting up dotfiles repository..."

# Check if we're already in the dotfiles directory
CURRENT_DIR="$(pwd)"
if [[ "$CURRENT_DIR" == *"dotfiles"* ]] && [ -f "bootstrap.sh" ]; then
    echo "✅ Running from dotfiles directory"
    DOTFILES_DIR="$CURRENT_DIR"
elif [ ! -d "$DOTFILES_DIR" ]; then
    if command -v git &> /dev/null; then
        git clone https://github.com/emeraldocean123/dotfiles.git "$DOTFILES_DIR"
        echo "✅ Dotfiles cloned successfully"
    else
        echo "⚠️  Git not found. Please install git or manually clone dotfiles to $DOTFILES_DIR"
        echo "📂 For NixOS: Use 'nix-shell -p git' or add git to your system configuration"
        exit 1
    fi
else
    echo "✅ Dotfiles directory already exists"
    if command -v git &> /dev/null; then
        cd "$DOTFILES_DIR"
        echo "🔄 Pulling latest changes..."
        git pull origin main || echo "⚠️  Could not pull latest changes (continuing anyway)"
    else
        echo "ℹ️  Git not available - skipping update check"
    fi
fi

# ----------------------------------------
# 4. Linking Functions
# ----------------------------------------
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
    
    echo "🔗 Linking directory $source -> $target"
    ln -sf "$source" "$target"
}

# ----------------------------------------
# 5. Link all configuration files
# ----------------------------------------
echo "🔗 Linking configuration files..."

# Bash configuration files
link_file "bashrc" ".bashrc"
link_file "bash_profile" ".bash_profile" 
link_file "bash_aliases" ".bash_aliases"

# Git configuration
link_file "gitconfig" ".gitconfig"

# Oh My Posh themes directory
link_dir "posh-themes" ".poshthemes"

# ----------------------------------------
# 5b. Setup PowerShell configuration (if available)
# ----------------------------------------
if [ "$POWERSHELL_AVAILABLE" = "true" ]; then
    echo "💙 Setting up PowerShell configuration..."
    
    # Determine PowerShell profile directory based on environment
    if [[ "$IS_WSL" = "true" ]]; then
        # In WSL, PowerShell profile goes to Windows Documents
        WINDOWS_DOCS="/mnt/c/Users/$USER/Documents"
        if [ ! -d "$WINDOWS_DOCS" ]; then
            # Try alternative path
            WINDOWS_DOCS="/mnt/c/Users/${USER^}/Documents"
        fi
        PS_PROFILE_DIR="$WINDOWS_DOCS/PowerShell"
    else
        # Native Linux PowerShell
        PS_PROFILE_DIR="$HOME/.config/powershell"
    fi
    
    if [ -d "$DOTFILES_DIR/powershell" ]; then
        mkdir -p "$PS_PROFILE_DIR"
        
        # Link PowerShell profile
        PS_PROFILE_TARGET="$PS_PROFILE_DIR/Microsoft.PowerShell_profile.ps1"
        PS_PROFILE_SOURCE="$DOTFILES_DIR/powershell/Microsoft.PowerShell_profile.ps1"
        
        if [ -f "$PS_PROFILE_TARGET" ] || [ -L "$PS_PROFILE_TARGET" ]; then
            echo "📋 Backing up existing PowerShell profile"
            mv "$PS_PROFILE_TARGET" "$BACKUP_DIR/Microsoft.PowerShell_profile.ps1"
        fi
        
        echo "🔗 Linking PowerShell profile: $PS_PROFILE_SOURCE -> $PS_PROFILE_TARGET"
        ln -sf "$PS_PROFILE_SOURCE" "$PS_PROFILE_TARGET"
        
        echo "✅ PowerShell configuration linked"
    else
        echo "⚠️  PowerShell configuration not found in dotfiles"
    fi
else
    echo "💙 PowerShell not available - skipping PowerShell configuration"
fi

# ----------------------------------------
# 6. Install Oh My Posh (skip on NixOS - use flake instead)
# ----------------------------------------
if [ "$NONFREE_INSTALL" = "true" ]; then
    echo "🎨 Installing Oh My Posh..."
    mkdir -p "$HOME/.local/bin"
    
    # Download Oh My Posh if not already installed
    if [ ! -f "$HOME/.local/bin/oh-my-posh" ]; then
        curl -s https://api.github.com/repos/JanDeDobbeleer/oh-my-posh/releases/latest \
        | grep "browser_download_url.*linux-amd64" \
        | cut -d '"' -f 4 \
        | wget -i - -O "$HOME/.local/bin/oh-my-posh"
        chmod +x "$HOME/.local/bin/oh-my-posh"
        echo "✅ Oh My Posh installed"
    else
        echo "✅ Oh My Posh already installed"
    fi
    
    # Only update .bashrc if not using our linked version
    if [ ! -L "$HOME/.bashrc" ]; then
        echo "📝 Updating .bashrc with Oh My Posh configuration..."
        BASHRC="$HOME/.bashrc"
        
        if ! grep -q "oh-my-posh init bash" "$BASHRC"; then
cat << 'EOF' >> "$BASHRC"

# ----------------------------------------
# Custom shell configuration
# ----------------------------------------

# Add user's local bin directory to PATH
export PATH="$HOME/.local/bin:$PATH"

# Source aliases from ~/.bash_aliases if the file exists
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Initialize Oh My Posh with the jandedobbeleer theme
if command -v oh-my-posh &> /dev/null && [ -f ~/.poshthemes/jandedobbeleer.omp.json ]; then
    eval "$(oh-my-posh init bash --config ~/.poshthemes/jandedobbeleer.omp.json)"
fi
EOF
        fi
    else
        echo "✅ Using linked .bashrc (Oh My Posh config managed by dotfiles)"
    fi
else
    echo "🎨 Skipping Oh My Posh installation on NixOS (available in flake.nix)"
fi

# ----------------------------------------
# 7. Set up Nix environment (if available)
# ----------------------------------------
if command -v nix &> /dev/null; then
    echo "❄️  Nix detected - setting up development shell..."
    cd "$DOTFILES_DIR"
    
    # Create system symlinks for VS Code compatibility
    if [ "$ID" != "nixos" ] && [ ! -L /usr/local/bin/nix ]; then
        echo "🔗 Creating system Nix symlinks for VS Code..."
        if command -v sudo &> /dev/null; then
            sudo ln -sf "$(which nix)" /usr/local/bin/nix 2>/dev/null || echo "⚠️  Could not create system nix symlink"
            sudo ln -sf "$(which nix-instantiate)" /usr/local/bin/nix-instantiate 2>/dev/null || echo "⚠️  Could not create system nix-instantiate symlink"
        fi
    fi
    
    echo "✅ Nix environment ready"
else
    echo "❄️  Nix not found (install separately if needed)"
fi

# ----------------------------------------
# 8. Final setup and reload
# ----------------------------------------
echo ""
echo "✨ Bootstrap complete!"
echo "🔄 Configuration files linked and ready"
echo "📦 Backups saved to: $BACKUP_DIR"

# Show what was linked
echo ""
echo "🔗 Linked configuration files:"
ls -la "$HOME" | grep -E "\.(bashrc|bash_profile|bash_aliases|gitconfig)" | grep -E "$DOTFILES_DIR" || echo "No bash/git file links found"
ls -la "$HOME" | grep "\.poshthemes" | grep -E "$DOTFILES_DIR" || echo "No poshthemes link found"

# Show PowerShell configuration if applicable
if [ "$POWERSHELL_AVAILABLE" = "true" ]; then
    echo ""
    echo "💙 PowerShell configuration:"
    if [[ "$IS_WSL" = "true" ]]; then
        WINDOWS_DOCS="/mnt/c/Users/$USER/Documents"
        if [ ! -d "$WINDOWS_DOCS" ]; then
            WINDOWS_DOCS="/mnt/c/Users/${USER^}/Documents"
        fi
        PS_PROFILE_DIR="$WINDOWS_DOCS/PowerShell"
    else
        PS_PROFILE_DIR="$HOME/.config/powershell"
    fi
    
    if [ -L "$PS_PROFILE_DIR/Microsoft.PowerShell_profile.ps1" ]; then
        echo "✅ PowerShell profile linked: $PS_PROFILE_DIR/Microsoft.PowerShell_profile.ps1"
    else
        echo "⚠️  PowerShell profile not linked"
    fi
fi

echo ""
echo "🎯 Next steps:"
if [ "$ID" = "nixos" ]; then
    echo "  • For NixOS: Run 'nix develop' in the dotfiles directory"
    echo "  • Or add the flake to your NixOS configuration"
else
    echo "  • Restart your terminal or run 'source ~/.bashrc'"
    echo "  • Optional: Install Nix for the development shell environment"
fi

if [ "$POWERSHELL_AVAILABLE" = "true" ]; then
    echo "  • For PowerShell: Restart PowerShell or run '. \$PROFILE'"
    echo "  • Test PowerShell profile with: $POWERSHELL_CMD -c 'Get-Command Get-*'"
fi

echo ""
echo "🎉 Your dotfiles environment is ready!"
