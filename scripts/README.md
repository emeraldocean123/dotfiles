# Utility Scripts

Most automation has moved to the shared toolkit in `~/Documents/dev/shared/scripts`. That repository contains the actively maintained bootstrap, validation, maintenance, and backup helpers used across machines.

This `scripts/` directory now holds a few dotfiles-specific helpers and symlinks:

- `ssh-utilities/` – wrappers for connecting to hosts and testing connectivity (`connect-host.ps1`, `test-ssh-connectivity.ps1`).
- `powershell/lint-powershell.ps1` – runs PSScriptAnalyzer with the repo settings.
- `powershell/setup-claude.ps1` – copies the shared Claude Code configuration into `~/.claude`.

Any new cross-repo automation should be added to `~/Documents/dev/shared/scripts` and (if needed) referenced from here.
