---
mode: "agent"
tools: []
description: "Clean up PowerShell environment following best practices"
---

# PowerShell Environment Cleanup

You are tasked with cleaning up a PowerShell environment in VS Code. Follow these steps systematically:

## Phase 1: Assessment
1. Scan the PowerShell directory: `${workspaceFolder}/Documents/PowerShell` or `$env:USERPROFILE\OneDrive\Documents\PowerShell`
2. Identify temporary files, duplicate profiles, and cleanup opportunities
3. Calculate potential space savings
4. Report findings before making any changes

## Phase 2: Temporary File Cleanup
Clean up these file patterns:
- `*.FIXED.ps1`, `*.MINIMAL.ps1`, `*.TEST.ps1`
- `troubleshoot-*.ps1`, `debug-*.ps1`
- `*.tmp`, `*.bak`, `*.old`
- Duplicate profiles with timestamps or backup names

## Phase 3: Profile Optimization
1. Verify the main profile: `Microsoft.PowerShell_profile.ps1`
2. Check for and remove duplicate functions or imports
3. Ensure robust error handling
4. Synchronize with dotfiles version if applicable
5. Test profile syntax and functionality

## Phase 4: Verification
1. Run profile verification script: `powershell/Verify-Profile.ps1`
2. Test key functions: `ll`, `la`, `gs`, `which`, etc.
3. Ensure no syntax errors
4. Verify module imports work correctly
5. Optionally validate the unified theme JSON:
	- Windows: `scripts/check-theme.ps1`
	- Linux: `scripts/check-theme.sh`

## Phase 5: Documentation
1. Update cleanup documentation
2. Record space savings and changes made
3. Note any issues or recommendations

## Important Guidelines
- **Always ask permission** before deleting non-temporary files
- **Preserve** Scripts/, Modules/, and documentation files
- **Test thoroughly** after making changes
- **Document everything** for transparency

[Reference the PowerShell cleanup instructions](../instructions/powershell-cleanup.instructions.md) for detailed guidelines.

Begin with Phase 1 assessment and proceed systematically through each phase.
