# Dotfiles - Cross-Platform Development Environment

This repository provides cross-platform shell, prompt, and tooling configuration for a consistent developer experience across Windows and Linux (including NixOS).

## Repository structure (key paths)

- Shell configs: `bashrc`, `powershell/Microsoft.PowerShell_profile.ps1`
- Prompt theme: `posh-themes/jandedobbeleer.omp.json` (single source of truth)
- PowerShell vendor: `modules/PSReadLine/2.4.1/` (pinned PSReadLine assets)
- Bootstrap scripts: `bootstrap.ps1`, `bootstrap.sh` (safe copy, not symlink)
- Cleanup helpers: `cleanup-dotfiles.ps1`, `cleanup-dotfiles.sh`
- Nix integration: `flake.nix`, `flake.lock`, `home.nix` (for Home Manager use)

## Platform support

- Windows: PowerShell profile, Oh My Posh prompt, vendored PSReadLine
- Linux/NixOS: Bash configs; Home Manager module consumes this repo (flake input)
- Cross‑platform: Git config, aliases, and shared helpers

## Unified prompt and theme

- Single theme file lives at `posh-themes/jandedobbeleer.omp.json`.
- PowerShell profile loads it from `~/Documents/dotfiles/...` when present.
- NixOS/Home Manager references the same file via a flake input to this repo.

## Bootstrap & deployment

- Windows: Run `bootstrap.ps1` to install core tools (if needed) and copy the profile. It backs up any existing profile and pins PSReadLine 2.4.1 from `modules/PSReadLine/2.4.1/`.
- Linux (non‑Nix): Use `bootstrap.sh` to copy `.bashrc` safely (no symlinks).
- NixOS: Prefer using this repo as a flake input from your `nixos-config` repository (Home Manager wires prompt/theme; no manual bootstrap required).

## Configuration guidelines

File organization
- Separate platform‑specific vs shared configuration.
- Keep names descriptive and group related settings logically.
- Maintain backward compatibility when feasible.

Code quality
- Comment rationale for non‑obvious choices (e.g., vendoring PSReadLine).
- Keep formatting consistent; use `nix fmt` when editing Nix files.
- Test on the target platform(s) after changes.

Deployment
- Provide automated setup paths (bootstrap scripts, Home Manager modules).
- Preserve existing configs with backups when overwriting.
- Document platform‑specific requirements and caveats.

## Cleanup guidance for AI assistants

- Follow `.github/instructions/powershell-cleanup.instructions.md` for PowerShell cleanup tasks.
- Remove only temporary or explicitly marked troubleshooting files; never delete vendored modules or the unified theme.
- Prefer pattern‑based scanning, report before removal, and verify after cleanup.

## NixOS integration

- This repo is consumed by `nixos-config` as a flake input for Home Manager, ensuring the same prompt/theme across hosts.
- Avoid duplicating the theme or profiles inside the system repo; reference this repo instead.

## Guardrails for AI changes

- Keep the Oh My Posh theme a single source of truth in `posh-themes/`.
- Do not modify vendored `modules/PSReadLine/2.4.1/` contents without also updating the pinned version in scripts and testing on Windows.
- Honor fastfetch guards (NO_FASTFETCH and FASTFETCH_SHOWN) to avoid duplicate banners.
- Prefer copy (not symlink) semantics in bootstrap unless explicitly requested otherwise.

## Integration notes

- Works alongside the separate `nixos-config` repository for Linux hosts.
- Provides a consistent experience for local and remote shells.

For details on using instruction files with Copilot in this repo, see `COPILOT-INTEGRATION-SUMMARY.md`.
