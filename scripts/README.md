# Utility Scripts

This directory contains utility scripts for system management and automation.

## Directory Structure

```
scripts/
├── obs-backup/
│   ├── OBS_ProfileBackup.ps1    # Backup OBS Studio profiles
│   └── OBS_ProfileRestore.ps1   # Restore OBS Studio profiles
└── README.md                    # This file
```

## OBS Backup Scripts

Located in `obs-backup/`, these PowerShell scripts help manage OBS Studio configuration:

### OBS_ProfileBackup.ps1
Backs up OBS Studio profiles and scenes to a specified location.

### OBS_ProfileRestore.ps1  
Restores OBS Studio profiles and scenes from backup.

## Usage

### OBS Backup
```powershell
# Run backup script
.\scripts\obs-backup\OBS_ProfileBackup.ps1
```

### OBS Restore
```powershell
# Run restore script
.\scripts\obs-backup\OBS_ProfileRestore.ps1
```

## Integration

These scripts can be:
- Run manually when needed
- Integrated into automated backup workflows
- Called from other scripts for system setup

## Future Scripts

This directory can be expanded with additional utility scripts for:
- Application setup automation
- Configuration synchronization  
- System maintenance tasks
- Development environment setup