# Claude Code Configuration

This directory contains Claude Code configuration files for consistent AI development environment setup.

## Files

- **`settings.json`** - Claude Code settings with custom status line and PowerShell 7 preference
- **`claude_desktop_config.json`** - Working directories configuration for multi-repository workflow
- **`setup-claude.ps1`** - PowerShell script to install configurations to `~/.claude/`

## Features

### Custom Status Line
Displays a colorful status line with:
- 👤 **User** - Current username (purple background)
- 📁 **Directory** - Current working directory (pink background)  
- 🌿 **Git Branch** - Current git branch if in repo (yellow background)
- ⚡ **Model** - Claude model being used (gray background)
- 🔧 **Project** - Current project name (green background)

### PowerShell 7 Integration
- Configured to use PowerShell 7 (`pwsh`) by default
- Works with Oh My Posh themes and advanced PowerShell features
- Compatible with the dotfiles PowerShell profile configuration

### Multi-Repository Workspace
Pre-configured working directories:
- `dotfiles` - Shell configurations and themes
- `bookmark-cleaner` - Python bookmark management tool
- `docs` - Technical documentation
- `nixos-config` - NixOS system configurations

## Installation

Run the setup script from PowerShell:

```powershell
.\setup-claude.ps1
```

This will copy the configuration files to `~/.claude/` directory.

## Manual Installation

Alternatively, copy files manually:

```powershell
# Copy settings
Copy-Item .\claude\settings.json ~/.claude/settings.json

# Copy desktop config  
Copy-Item .\claude\claude_desktop_config.json ~/.claude/claude_desktop_config.json
```

## Usage

After installation, Claude Code will:
- Use PowerShell 7 for all shell commands
- Display the custom colorful status line
- Have quick access to all working directories
- Integrate seamlessly with the dotfiles PowerShell profile

Launch Claude Code from any of the configured directories for the best experience.