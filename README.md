# 🛠️ Joseph's Dotfiles

This repository contains my personal shell configuration files and a cross-platform bootstrap script to quickly set up a consistent development environment across WSL, Linux distros, and more.

---

## 📦 What It Sets Up

- **Custom shell aliases** (`bash_aliases`) - `ll`, `gs`, `..`
- **[Oh My Posh](https://ohmyposh.dev) prompt** with the `jandedobbeleer` theme
- **Essential CLI tools**: `git`, `curl`, `wget`, `nano`, `unzip`
- **Smart OS detection** (Debian, Ubuntu, NixOS, Arch) for package installation
- **PowerShell profile** with enhanced modules (PSReadLine, Terminal-Icons, z, PSFzf)
- **Cross-platform compatibility** - Works in WSL, Linux, Windows, macOS
- **Automatic configuration** with symlinks and backup management

---

## 🌍 Cross-Platform Compatibility

This setup works seamlessly across:

- **WSL** (Windows Subsystem for Linux) - Both Debian and NixOS
- **Native Linux** - Debian, Ubuntu, Arch, NixOS
- **Windows PowerShell** - Both Windows PowerShell and PowerShell Core
- **Cross-platform PowerShell** - Linux and macOS PowerShell installations
- **Debian/Ubuntu** - Full Oh My Posh installation with themes  
- **NixOS** - Uses flake.nix for dependency management, skips manual package installation
- **Any Unix-like system** - Bash configuration and aliases

The bootstrap script automatically detects your system and adapts accordingly:
- On Debian/Ubuntu: Installs packages with apt and Oh My Posh
- On NixOS: Skips package installation, recommends using flake.nix
- On Arch: Uses pacman for package installation
- **PowerShell detected**: Links PowerShell profile and modules
- **In WSL**: Automatically maps PowerShell profile to Windows Documents
- Everywhere: Creates symlinks and manages backups safely

---

## 🚀 Quick Start

### 1. Clone this repository

```bash
git clone https://github.com/emeraldocean123/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Run the bootstrap script

#### Option A: Unified Bash Bootstrap (Linux/WSL)
The unified bootstrap script works across all platforms and handles everything:

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

#### Option B: PowerShell Bootstrap (Windows/Cross-platform PowerShell)
For Windows or any system with PowerShell:

```powershell
# From PowerShell
.\bootstrap.ps1

# Or with options
.\bootstrap.ps1 -SkipModuleInstall  # Skip PowerShell module installation
```

**What the scripts do:**
- 🔍 **Detects your OS** (Debian/Ubuntu, NixOS, Arch, Windows, etc.)
- 📦 **Installs essential packages** (git, curl, wget, nano, unzip)
- 📂 **Clones/updates dotfiles** repository if needed
- 💾 **Backs up existing configs** to timestamped backup folder
- 🔗 **Creates symlinks** for all configuration files (no duplicates)
- 🎨 **Installs Oh My Posh** (except on NixOS - uses flake.nix instead)
- 💙 **Sets up PowerShell** profile and modules (if PowerShell available)
- ❄️ **Sets up Nix environment** if available
- 🔧 **Configures VS Code compatibility** for Nix
- ✨ **Prevents PATH duplication** and handles edge cases

### 3. Verify installation

After running the bootstrap script, test your new environment:

#### Bash/Linux environments:
```bash
# Test bash aliases
source ~/.bashrc
ll  # Should work like 'ls -lah' (from bash_aliases)
gs  # Should work like 'git status'
..  # Should work like 'cd ..'

# Check Oh My Posh theme (non-NixOS systems)
oh-my-posh --version  # Should show version if installed
```

#### PowerShell environments:
```powershell
# Restart PowerShell and test
. $PROFILE
Get-Command Get-*  # Should show enhanced command discovery
z <tab>  # Should show z-directory navigation
```

### 4. NixOS/Nix Development Shell

For enhanced development environment with all tools:

```bash
nix develop  # Enters the flake shell environment
```

### 5. NixOS Home Manager Integration

If you're using NixOS with Home Manager, you can integrate these dotfiles directly into your Home Manager configuration for a declarative setup. This eliminates the need to run the bootstrap script and manages everything through Nix.

**Example integration** (see [nixos-config](https://github.com/emeraldocean123/nixos-config) for full examples):

```nix
# home/<hostname>/joseph.nix
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    oh-my-posh
    fzf
    # ... other packages
  ];

  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -lah";
      gs = "git status";
      ".." = "cd ..";
    };
    
    bashrcExtra = ''
      # Oh My Posh prompt
      if command -v oh-my-posh &> /dev/null; then
        eval "$(oh-my-posh init bash --config ${pkgs.oh-my-posh}/share/oh-my-posh/themes/jandedobbeleer.omp.json)"
      fi
    '';
  };

  programs.git = {
    enable = true;
    userName = "Joseph";
    userEmail = "emeraldocean123@users.noreply.github.com";
  };
}
```

**Benefits of Home Manager integration:**
- ✅ **Declarative configuration** - Everything defined in Nix
- ✅ **Reproducible** - Exact same environment on any NixOS machine
- ✅ **Version controlled** - All changes tracked in git
- ✅ **Atomic updates** - All or nothing configuration changes
- ✅ **Rollback support** - Easy to revert to previous configurations

To rebuild your Home Manager configuration:
```bash
home-manager switch
```

---

## 📁 Structure

- `bashrc` - Main bash configuration file with clean prompt
- `bash_profile` - Bash profile for login shells
- `bash_aliases` - Custom shell aliases and functions
- `gitconfig` - Git configuration with user settings
- `posh-themes/` - Oh My Posh theme configurations
  - `jandedobbeleer.omp.json` - Custom prompt theme
- `bootstrap.sh` - Unified cross-platform setup script for Unix/Linux
- `bootstrap.ps1` - Cross-platform PowerShell setup script
- `flake.nix` - Nix development shell configuration
- `powershell/` - PowerShell-specific configurations
  - `Microsoft.PowerShell_profile.ps1` - PowerShell profile
  - `setup.ps1` - Legacy PowerShell setup script

---

## 🛠️ What Gets Configured

- **Shell aliases** for productivity (bash)
- **Oh My Posh** prompt with jandedobbeleer theme
- **Essential tools**: git, curl, wget, nano, unzip
- **PowerShell profile** with enhanced modules (Windows/Linux/macOS)
- **PowerShell modules**: PSReadLine, Terminal-Icons, z, PSFzf
- **Nix development environment** (cross-platform)
- **Cross-platform compatibility** - Works in WSL, Linux, Windows

---

## 🔧 Troubleshooting

### Configuration not loading in terminal?
```bash
# Method 1: Reload configuration
source ~/.bashrc

# Method 2: Start new shell session
exec bash -l

# Method 3: Check if symlinks exist
ls -la ~ | grep -E '\.(bashrc|bash_aliases)'
```

### Aliases not working?
```bash
# Check if aliases are loaded
alias | grep ll

# Manually source bash_aliases
source ~/.bash_aliases

# Verify alias definition
cat ~/.bash_aliases
```

### Oh My Posh not showing?
```bash
# Check if Oh My Posh is installed
oh-my-posh --version

# Check if themes directory exists
ls ~/.poshthemes/

# Verify PATH includes ~/.local/bin
echo $PATH | grep ".local/bin"
```

### PowerShell profile not loading?
```powershell
# Check profile path
$PROFILE

# Test if profile exists
Test-Path $PROFILE

# Manually load profile
. $PROFILE
```

### PATH duplication issues?
The current configuration prevents PATH duplication. If you see duplicates, restart your terminal or run:
```bash
exec bash -l
```

### NixOS Home Manager issues?
```bash
# Check Home Manager status
home-manager --version

# Rebuild configuration
home-manager switch

# Check if packages are available
which oh-my-posh
which fzf

# View current generation
home-manager generations

# Rollback if needed
home-manager switch --switch-generation <number>
```

### NixOS dotfiles not working with bootstrap script?
On NixOS, the bootstrap script intentionally skips package installation since packages should be managed through your NixOS configuration or Home Manager. If you need to use the bootstrap script for symlinks only:

```bash
# The script will still create symlinks but skip package installation
./bootstrap.sh

# Or use Home Manager integration instead (recommended)
# Add the configuration to your home/<hostname>/user.nix file
```

---

## 📝 License

MIT License - see repository for details.
