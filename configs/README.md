# Application Configurations

This directory contains configuration files for various applications that should be synced across machines.

## Directory Structure

```
configs/
├── vscode/
│   └── settings.json      # VS Code user settings
├── obs/
│   ├── profiles/          # OBS Studio profiles (future use)
│   └── scenes/            # OBS Studio scenes (future use)
└── README.md              # This file
```

## VS Code Settings

**Source**: `AppData/Roaming/Code/User/settings.json`
**Managed by**: Bootstrap script (future implementation)

Contains VS Code configuration including:
- GitHub Copilot settings
- Editor preferences
- Extension configurations
- Workspace preferences

## OBS Studio (Future)

OBS Studio configurations are currently backed up by the shared automation in `~/Documents/dev/shared/scripts/backup/` but profile and scene files could be managed here in the future if needed.

## Installation

These configurations are installed by the dotfiles bootstrap scripts. To manually install:

### VS Code Settings
```powershell
# Windows
Copy-Item "configs/vscode/settings.json" "$env:APPDATA/Code/User/settings.json" -Force
```

```bash
# Linux/macOS
cp configs/vscode/settings.json ~/.config/Code/User/settings.json
```