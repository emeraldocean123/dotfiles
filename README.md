# 🛠️ Joseph's Dotfiles

This repository contains my personal shell configuration files and a cross-platform bootstrap script to quickly set up a consistent development environment across WSL, Linux distros, and more.

---

## 📦 What It Sets Up

- Custom shell aliases (`bash_aliases`)
- [Oh My Posh](https://ohmyposh.dev) prompt with the `jandedobbeleer` theme
- Essential CLI tools: `git`, `curl`, `wget`, `nano`, `unzip`
- Smart OS detection (Debian, NixOS, Arch) for package installation
- Automatic `.bashrc` configuration with comments

---

## 🚀 Quick Start

### 1. Clone this repository

```bash
git clone https://github.com/emeraldocean123/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Choose your setup method

#### Option A: Fresh Install (bootstrap.sh)
For new systems where you want to install dependencies and set everything up:

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

#### Option B: Link Existing Config (link.sh)
If you already have the dotfiles and just want to create symlinks:

```bash
chmod +x link.sh
./link.sh
```

This will:
- Create backups of existing config files
- Symlink all dotfiles to your home directory
- Preserve your existing configurations in a timestamped backup folder

### 3. For PowerShell (Windows)

```powershell
cd dotfiles/powershell
.\setup.ps1
```

### 4. For NixOS/Nix users

```bash
nix develop  # Enters the flake shell environment
```

---

## 📁 Structure

- `bashrc` - Main bash configuration file with clean prompt
- `bash_profile` - Bash profile for login shells
- `bash_aliases` - Custom shell aliases and functions
- `gitconfig` - Git configuration with user settings
- `posh-themes/` - Oh My Posh theme configurations
  - `jandedobbeleer.omp.json` - Custom prompt theme
- `flake.nix` - Nix development shell configuration
- `bootstrap.sh` - Cross-platform setup script for fresh installs
- `link.sh` - Script to symlink all dotfiles to home directory
- `powershell/` - PowerShell-specific configurations
  - `Microsoft.PowerShell_profile.ps1` - PowerShell profile
  - `setup.ps1` - PowerShell setup script
- `bootstrap.sh` - Cross-platform setup script
- `flake.nix` - Nix flake for portable shell environment
- `powershell/` - PowerShell configuration files
  - `Microsoft.PowerShell_profile.ps1` - PowerShell profile
  - `setup.ps1` - PowerShell setup script

---

## 🛠️ What Gets Configured

- **Shell aliases** for productivity
- **Oh My Posh** prompt with jandedobbeleer theme
- **Essential tools**: git, curl, wget, nano, unzip
- **PowerShell profile** (Windows)
- **Nix development environment** (cross-platform)

---

## 📝 License

MIT License - see repository for details.
