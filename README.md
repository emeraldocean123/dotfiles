# Dotfiles

Cross‑platform shell, prompt, and tooling configuration for Bash and PowerShell, with Home Manager integration for Linux/NixOS.

## Structure (key paths)

### Core Shell Configuration
- PowerShell profiles: `powershell/Microsoft.PowerShell_profile.ps1` (boots vendored PSReadLine; sets Oh My Posh)
- Pinned PSReadLine (vendored): `modules/PSReadLine/2.4.1/`
- Unified Oh My Posh theme (single source of truth): `posh-themes/jandedobbeleer.omp.json`
- Bootstrap scripts live in `~/Documents/dev/shared/scripts/bootstrap/` (`bootstrap-windows.ps1`, `bootstrap-linux.sh`).
- Nix/Home Manager bits: `flake.nix`, `home.nix`

### Application Configurations
- Claude Code configuration: `~/Documents/dev/shared/configs/claude/` (copied via `scripts/powershell/setup-claude.ps1`).
- VS Code workspace: `configs/vscode-workspace/workspace.code-workspace`
- VS Code settings: `configs/vscode/settings.json`
- Git configuration: `git/gitconfig`
- SSH configuration: `ssh/config`

### Utility Scripts
- Setup utilities: Various setup and maintenance scripts

## Try it

- Windows (PowerShell):
	- Run `~/Documents/dev/shared/scripts/bootstrap/bootstrap-windows.ps1` to install core tools and copy the profile (backs up any existing profile).
	- The profile pins PSReadLine 2.4.1 from `modules/PSReadLine/2.4.1/` and loads the unified OMP theme.
	- In Copilot Chat, you can run the guided prompt `/bootstrap-dotfiles` (requires prompt files enabled).

- Linux (non‑Nix):
	- Run `~/Documents/dev/shared/scripts/bootstrap/bootstrap-linux.sh` to copy `.bashrc` (safe copy; no symlinks).

- NixOS/Home Manager:
	- Use this repo as a flake input from your system flake (see `nixos-config`).
	- Reference the theme via `inputs.dotfiles.outPath + "/posh-themes/jandedobbeleer.omp.json"`.

- Claude Code:
	- Run `scripts/powershell/setup-claude.ps1` to install Claude Code settings with custom status line and PowerShell 7 integration (sources files from `~/Documents/dev/shared/configs/claude`).
	- See `~/Documents/dev/shared/configs/claude/README.md` for detailed configuration information.

### Verify
- After bootstrap, run validation:
	- PowerShell: `~/Documents/dev/shared/scripts/validation/validate-environment.ps1 -PowerShell`
	- Theme only: `~/Documents/dev/shared/scripts/validation/validate-environment.ps1 -Theme`
	- SSH connectivity: `~/Documents/dev/shared/scripts/validation/validate-environment.ps1 -SSH`
	- Everything: `~/Documents/dev/shared/scripts/validation/validate-environment.ps1 -All`
	- Fastfetch guards are set to avoid duplicate banners

### SSH Utilities
- Test connectivity: `scripts/ssh-utilities/test-ssh-connectivity.ps1 -All`
- Connect to host: `scripts/ssh-utilities/connect-host.ps1 hp` (or msi, nas, proxmox, etc.)
- Interactive session: `scripts/ssh-utilities/connect-host.ps1 msi -Interactive`

## Troubleshooting

- Oh My Posh not found
	- Install oh-my-posh. On Windows, the profile auto-adds `%LOCALAPPDATA%/Programs/oh-my-posh/bin` to PATH.

- PSReadLine import fails / wrong version
	- Re-run `~/Documents/dev/shared/scripts/bootstrap/bootstrap-windows.ps1` to ensure the vendored 2.4.1 is copied/loaded.
	- Avoid installing conflicting PSReadLine versions globally.

- Duplicate fastfetch banner
	- Set `NO_FASTFETCH=1` to disable; the profile uses `FASTFETCH_SHOWN` to prevent duplicates.

- VS Code Integrated Terminal not picking profile
	- Confirm `$PROFILE` points to `powershell/Microsoft.PowerShell_profile.ps1` after bootstrap; relaunch VS Code.

- Validate Oh My Posh theme JSON
	- Windows: run `~/Documents/dev/shared/scripts/validation/check-theme.ps1`
	- Linux/macOS: run `pwsh -NoProfile -File ~/Documents/dev/shared/scripts/validation/check-theme.ps1`

## Guardrails

Do
- Keep `posh-themes/jandedobbeleer.omp.json` as the single source of truth.
- Pin and load PSReadLine 2.4.1 from `modules/PSReadLine/2.4.1/`.
- Use copy (not symlink) semantics in bootstrap; back up existing files first.
- Honor `NO_FASTFETCH` and `FASTFETCH_SHOWN` guards.

Don’t
- Don’t delete or modify vendored PSReadLine under `modules/PSReadLine/`.
- Don’t duplicate the theme in multiple locations or commit host-specific variants.
- Don’t add global overrides that break NixOS/Home Manager consumption of this repo.

## VS Code Integration

In VS Code, you can run these tasks from the Command Palette (Ctrl+Shift+P -> "Tasks: Run Task"):
- **Verify Dotfiles (All)** - runs both verification and theme checks
- **Verify PowerShell Profile** - runs `powershell/Verify-Profile.ps1`
- **Validate OMP Theme (Windows)** - runs `~/Documents/dev/shared/scripts/validation/check-theme.ps1` (PowerShell)
- **Validate OMP Theme (Linux/macOS)** - runs `pwsh -NoProfile -File ~/Documents/dev/shared/scripts/validation/check-theme.ps1`
- **Verify Dotfiles (Linux)** - runs consolidated Linux verification
- **Lint PowerShell (PSScriptAnalyzer)** - lints PowerShell scripts and modules (excludes vendored PSReadLine)
 - **Lint PowerShell (CI format)** - same lint but with plain output + VS Code Problems integration
 - **Lint PowerShell (baseline)** - runs lint without custom settings (useful for quick triage)

For Copilot users, enable prompt files:
```json
{
  "github.copilot.chat.codeGeneration.useInstructionFiles": true,
  "chat.promptFiles": true
}
```
Then use `/bootstrap-dotfiles` and `/cleanup-powershell` prompts.

## Common Aliases

These aliases are configured across all platforms (PowerShell, Bash, NixOS):

| Alias | Description | Command |
|-------|-------------|---------|
| `ll` | Detailed listing with hidden files | `ls -la` |
| `la` | Same as ll | `ls -la` |
| `gs` | Git status | `git status` |
| `ga` | Git add | `git add` |
| `gc` | Git commit | `git commit` |
| `gp` | Git push | `git push` |
| `gl` | Last 10 git commits | `git log --oneline -10` |
| `gd` | Git diff | `git diff` |
| `..` | Go up one directory | `cd ..` |

## Formatting (optional)

If you have Nix:
- `nix fmt` (nixpkgs-fmt)
- `nix develop` for a dev shell

On Windows without Nix, use WSL or skip.

Editor/IDE
- `.editorconfig` enforces consistent basics (LF, UTF-8, 2/4-space indents)
- VS Code: recommended extensions in `.vscode/extensions.json`
 - PSScriptAnalyzer settings: tune rules in `PSScriptAnalyzerSettings.psd1` (pass -NoSettings to ignore)
 - CI artifacts: manual workflow uploads `pssa-linux.txt` and `pssa-windows.txt` for download
## Conventional Commits & Hooks

- Commit Template: this repo ships a shared template at `git-templates/commit_template.txt`. Your global Git is configured to use it automatically. Run `git commit` and fill the header `type(scope)?: subject` following Conventional Commits.
- Shared Hooks: global `core.hooksPath` points to `Documents/dev/dotfiles/githooks`.
  - `pre-commit`: blocks private keys, `.env*`, package-lock.json (when `bun.lock` exists), files > 5MB, and scans for common secrets. Add regex entries to `.githooks-allow.txt` to suppress known safe files.
  - `commit-msg`: enforces Conventional Commits. Set `GITHOOKS_BYPASS=1` to bypass once (not recommended).
- New repos: inherit hooks via the global `core.hooksPath`; nothing extra to configure.

## WSL + Nix Bootstrap

- Scripts live in `Documents/dev/nixos-config/tools/wsl/`:
  - `bootstrap-nix-debian.sh`: enables flakes, installs Nix, reuses unified SSH key, clones `nixos-config`, runs `nix flake check`.
  - `open-debian-nixos-config.ps1`: launches Debian WSL inside the `nixos-config` workspace.
- See `CODEX.md` and `CLAUDE.md` for the unified workspace guide used by both assistants.

## Review Routing

- This repo uses CODEOWNERS; PRs request review from `@emeraldocean123` automatically.

## Contributing

- Use Conventional Commits for all messages: `type(scope)?: subject`.
- Commit Template: this repo is configured with a commit message template to guide messages.
- Hooks: shared `pre-commit` and `commit-msg` hooks run automatically (configured via global `core.hooksPath`).
- Bypass (rare): set `GITHOOKS_BYPASS=1` to skip checks once.
