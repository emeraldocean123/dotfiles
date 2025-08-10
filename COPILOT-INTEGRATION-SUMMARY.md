# VS Code Copilot Integration Summary

## Overview

This repository is fully integrated with VS Code Copilot's experimental prompt files feature, providing automated PowerShell environment cleanup and maintenance guidelines.

## Implementation Details

### 1. Custom Instructions (`.github/copilot-instructions.md`)

- **Purpose**: General guidelines for the entire dotfiles repository
- **Scope**: Applies to all Copilot chat requests in the workspace
- **Content**: PowerShell best practices, file management, error handling, VS Code integration, usage/quick start, troubleshooting, guardrails (theme/PSReadLine/fastfetch)
- **Auto-applies**: Yes, when `github.copilot.chat.codeGeneration.useInstructionFiles` is enabled

### 2. Specific Instructions (`.github/instructions/powershell-cleanup.instructions.md`)

- **Purpose**: Detailed PowerShell cleanup guidelines for AI assistants
- **Scope**: Applies to PowerShell files (`**/*.ps1`)
- **Content**: File patterns to clean, preservation rules, cleanup process
- **Auto-applies**: When working with PowerShell files

### 3. Prompt Files

- `.github/prompts/cleanup-powershell.prompt.md`
  - Purpose: Reusable cleanup automation prompt
  - Usage: `/cleanup-powershell`
- `.github/prompts/bootstrap-dotfiles.prompt.md`
  - Purpose: Guided bootstrap for Windows/Linux
  - Usage: `/bootstrap-dotfiles`

### 4. VS Code Tasks

- Tasks available under `.vscode/tasks.json`:
  - Verify PowerShell Profile
  - Validate OMP Theme (Windows)
  - Validate OMP Theme (Linux)

## How to Use

### Automatic Application

Instructions are automatically included when:

- Working with PowerShell files (`.ps1`)
- Using Copilot chat in this workspace
- The instruction files setting is enabled

### Manual Execution

Run the cleanup prompt:

```bash
/cleanup-powershell
```

### Required Settings

Ensure these VS Code settings are enabled:

```json
{
  "github.copilot.chat.codeGeneration.useInstructionFiles": true,
  "chat.promptFiles": true
}
```

### Try it

- In VS Code, open Command Palette → "Tasks: Run Task" and run:
  - "Verify PowerShell Profile"
  - "Validate OMP Theme (Windows)" or "Validate OMP Theme (Linux)"
- In Copilot Chat, run prompt commands:
  - `/bootstrap-dotfiles`
  - `/cleanup-powershell`

## Files Created

1. **`.github/copilot-instructions.md`** - General repository guidelines
2. **`.github/instructions/powershell-cleanup.instructions.md`** - PowerShell-specific instructions
3. **`.github/prompts/cleanup-powershell.prompt.md`** - Automated cleanup prompt
4. **`.github/prompts/bootstrap-dotfiles.prompt.md`** - Guided bootstrap prompt
5. **`powershell/Verify-Profile.ps1`** - PowerShell profile verification helper
6. **`scripts/check-theme.ps1`** and **`scripts/check-theme.sh`** - Theme JSON validation helpers
7. Repository files updated to reflect guardrails: `CONTRIBUTING.md`, `README.md`

## Benefits

- **Consistent AI behavior** across different Copilot sessions
- **Automated cleanup** following established best practices
- **Safe file management** with appropriate preservation rules
- **Documentation** of all AI-driven changes
- **Repeatable processes** for PowerShell environment maintenance
- Validation is done via local scripts and VS Code tasks on Windows and Linux (no GitHub Actions)

## Verification

The integration has been tested and verified to:

- ✅ Follow VS Code Copilot experimental prompt file specifications
- ✅ Provide consistent cleanup behavior
- ✅ Preserve important files while removing temporary ones
- ✅ Calculate and report space savings
- ✅ Document all changes made
- ✅ Run validations locally with the provided VS Code tasks (no GitHub Actions)

## Future Maintenance

This Copilot integration will ensure consistent PowerShell environment cleanup and maintenance across all future AI-assisted sessions in this workspace.
