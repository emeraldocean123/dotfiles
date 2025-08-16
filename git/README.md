# Git Configuration

This directory contains Git configuration that should be synced across machines.

## Files

- **`gitconfig`** - Global Git configuration

## Configuration Contents

The Git config includes:
- User identity (name and email)
- Pull behavior (rebase preference)  
- SSH command configuration for Windows
- GUI preferences

## Installation

The Git config is installed by the dotfiles bootstrap scripts. To manually install:

### Windows
```powershell
Copy-Item "git/gitconfig" "$env:USERPROFILE/.gitconfig" -Force
```

### Linux/macOS  
```bash
cp git/gitconfig ~/.gitconfig
```

## Customization

After installation, you may want to customize:
```bash
# Set your personal information
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"

# Platform-specific SSH command (Windows example already configured)
git config --global core.sshCommand "C:\\Windows\\System32\\OpenSSH\\ssh.exe"
```