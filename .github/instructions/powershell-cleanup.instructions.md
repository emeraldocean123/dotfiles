---
description: "Guidelines for AI assistants working with PowerShell environments in VS Code"
applyTo: "**/*.ps1"
---

# PowerShell Environment AI Instructions

## File Management Guidelines

When working with PowerShell environments, always follow these cleanup guidelines:

### Temporary Files to Clean Up
- Remove `*.FIXED.ps1`, `*.MINIMAL.ps1`, `*.TEST.ps1` files after troubleshooting
- Delete `troubleshoot-*.ps1` and `debug-*.ps1` debugging scripts  
- Clean up files with `.tmp`, `.bak`, `.old` extensions
- Remove duplicate profile files with timestamps or backup names

### Important Files to Preserve
- Keep `Microsoft.PowerShell_profile.ps1` (main profile)
- Preserve `powershell.config.json` (configuration)
- Maintain `Scripts/` and `Modules/` directories
- Keep documentation files (`*.md`)
- Preserve verification scripts unless explicitly requested to remove
 - Do not modify or delete vendored PSReadLine in `modules/PSReadLine/2.4.1/`
 - Do not modify or duplicate the unified Oh My Posh theme in `posh-themes/jandedobbeleer.omp.json`

### Cleanup Process
1. **Scan and identify** temporary files using pattern matching
2. **Report findings** with file names and sizes before removal
3. **Ask permission** before deleting non-temporary files
4. **Remove files safely** with proper error handling
5. **Calculate and report** space savings (KB/MB)
6. **Document changes** in cleanup plans or README files
7. **Verify functionality** after cleanup operations
8. **Honor profile guards** such as `NO_FASTFETCH` and `FASTFETCH_SHOWN` to avoid duplicate banners

### Profile Optimization
- Consolidate duplicate functions and imports
- Add robust error handling with graceful fallbacks
- Ensure both main and dotfiles profiles are synchronized
- Test profile syntax before finalizing changes
- Verify all key functions load successfully

### PowerShell-Specific Considerations
- Remember that Unix-style flags like `ls -la` don't work in PowerShell
- Use PowerShell-native functions: `ll`, `la`, `lsla` for directory listing
- Handle module import failures gracefully
- Check for VS Code PowerShell extension compatibility issues
