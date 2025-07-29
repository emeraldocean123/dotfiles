🛠️ Joseph's Dotfiles
This repository contains my personal shell configuration files and cross-platform bootstrap scripts to set up a consistent development environment across Windows, Linux (Debian, NixOS), and WSL.
📦 What It Sets Up

Custom shell aliases (bash_aliases, PowerShell profile) - ll, gs, gcom, ..
Oh My Posh prompt with the jandedobbeleer theme
Essential CLI tools: git, curl, wget, nano, unzip
Smart OS detection (Debian, Ubuntu, NixOS, Arch) for package installation
PowerShell profile with enhanced modules (PSReadLine, Terminal-Icons, z)
Cross-platform compatibility - Works in WSL, Linux, Windows
Automatic configuration with symlinks and backup management
NixOS integration via flake.nix and home.nix
VS Code Copilot integration for automated cleanup and maintenance

🌍 Cross-Platform Compatibility
This setup works seamlessly across:

WSL (Windows Subsystem for Linux) - Debian and NixOS
Native Linux - Debian, Ubuntu, Arch, NixOS
Windows PowerShell - PowerShell Core
Debian/Ubuntu - Full Oh My Posh installation with themes
NixOS - Uses flake.nix for dependency management
Any Unix-like system - Bash configuration and aliases

The bootstrap scripts (bootstrap.sh, bootstrap.ps1) detect your system and adapt:

Debian/Ubuntu: Installs packages with apt
NixOS: Skips package installation, uses flake.nix
Arch: Uses pacman
WSL: Maps PowerShell profile to Windows Documents
Everywhere: Creates symlinks and manages backups

🚀 Quick Start
1. Clone this repository
git clone https://github.com/emeraldocean123/dotfiles.git ~/dotfiles
cd ~/dotfiles

2. Run the bootstrap script
Option A: Unified Bash Bootstrap (Linux/WSL)
chmod +x bootstrap.sh
./bootstrap.sh

Option B: PowerShell Bootstrap (Windows/Cross-platform PowerShell)
.\bootstrap.ps1
# Or with options
.\bootstrap.ps1 -SkipModuleInstall  # Skip PowerShell module installation

What the scripts do:

🔍 Detects your OS (Debian/Ubuntu, NixOS, Arch, Windows)
📦 Installs essential packages (git, curl, wget, nano, unzip)
📂 Clones/updates dotfiles repository
💾 Backs up existing configs to timestamped folder
🔗 Creates symlinks for configs (no duplicates)
🎨 Installs Oh My Posh (except on NixOS)
💙 Sets up PowerShell profile and modules
❄️ Sets up Nix environment (if available)
🔧 Configures VS Code Copilot compatibility
✨ Prevents PATH duplication

3. Verify installation
Bash/Linux environments:
source ~/.bashrc
ll  # Like 'ls -lah'
gs  # Like 'git status'
gcom -m "Test commit"  # Like 'git commit -m'
oh-my-posh --version  # Check Oh My Posh

PowerShell environments:
. $PROFILE
ll
gs
gcom -m "Test commit"
z <tab>  # Z-directory navigation

4. NixOS/Nix Development Shell
nix develop  # Enters flake shell environment

5. NixOS Home Manager Integration
Integrate with Home Manager for a declarative setup:
# home/<hostname>/joseph.nix
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    oh-my-posh
    fzf
    zoxide
  ];
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -lah --color=auto";
      gs = "git status";
      gcom = "git commit";
      ".." = "cd ..";
    };
    bashrcExtra = ''
      if command -v oh-my-posh &> /dev/null; then
        eval "$(oh-my-posh init bash --config ~/.poshthemes/jandedobbeleer.omp.json)"
      fi
    '';
  };
  programs.git = {
    enable = true;
    userName = "Joseph";
    userEmail = "emeraldocean123@users.noreply.github.com";
  };
}

Rebuild:
home-manager switch

📁 Structure

.github/ - VS Code Copilot integration
.gitignore - Git ignore rules
COPILOT-INTEGRATION-SUMMARY.md - Copilot setup documentation
bash_aliases - Cross-platform shell aliases
bash_profile - Bash profile for login shells
bashrc - Bash configuration for non-login shells
bootstrap.ps1 - PowerShell setup script
bootstrap.sh - Bash setup script for Unix/Linux
cleanup-dotfiles.ps1 - PowerShell cleanup script
flake.lock, flake.nix - Nix development shell
home.nix - Home Manager configuration for NixOS
gitconfig - Git user settings
link.sh - Symlink creation script
powershell/Microsoft.PowerShell_profile.ps1 - PowerShell profile
posh-themes/jandedobbeleer.omp.json - Oh My Posh theme
README.md - This file
SYNC-GUIDE.md - Cross-platform sync guide

🛠️ Troubleshooting
Configuration not loading?
source ~/.bashrc
exec bash -l
ls -la ~ | grep -E '\.(bashrc|bash_aliases)'

Aliases not working?
alias | grep ll
source ~/.bash_aliases
cat ~/.bash_aliases

Oh My Posh not showing?
oh-my-posh --version
ls ~/.poshthemes/
echo $PATH | grep ".local/bin"

PowerShell profile not loading?
$PROFILE
Test-Path $PROFILE
. $PROFILE

NixOS Home Manager issues?
home-manager --version
home-manager switch
which oh-my-posh
home-manager generations

📝 Cleanup Log

2025-07-29: Removed temporary/test files (debug-nixos-wsl.sh, NIXOS-DEBUG-WSL.sh, archive/Microsoft.PowerShell_profile.complex.backup.ps1, test.txt). Saved ~0 MB.
2025-07-29: Fixed Git aliases in Microsoft.PowerShell_profile.ps1 (Version: 2025.9) to use functions for correct subcommand handling.

📝 License
MIT License - see repository for details.# Test SSH push

- 2025-07-29: Configured Git to use SSH in WSL, updated README.md to latest version.
