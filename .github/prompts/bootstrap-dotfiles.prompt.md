---
mode: "agent"
tools: []
description: "Bootstrap dotfiles on Windows or Linux safely"
---

# Dotfiles Bootstrap Guide

You are tasked with bootstrapping this dotfiles repo on a new machine (Windows PowerShell or Linux Bash). Follow these steps, honoring the guardrails in `.github/copilot-instructions.md`.

## Phase 1: Assess
1. Verify repo structure exists in `~/Documents/dev/dotfiles` (Windows) or `~/Documents/dev/dotfiles` (Linux)
2. Confirm key files:
   - `powershell/Microsoft.PowerShell_profile.ps1`
   - `posh-themes/jandedobbeleer.omp.json` (single source of truth)
   - `modules/PSReadLine/2.4.1/` (vendored PSReadLine)
3. Report missing files before proceeding.

## Phase 2: Bootstrap
- Windows (PowerShell):
  1. Install core tools if missing: Git, Oh My Posh, Fastfetch (winget)
  2. Copy profile with backup: run `bootstrap.ps1` (copy semantics; never symlink)
- Linux (non‑Nix):
  1. Copy bashrc with backup: run `bootstrap.sh`
- NixOS/Home Manager: Do not bootstrap; reference this repo as a flake input.

## Phase 3: Verify
1. In PowerShell, run `powershell/Verify-Profile.ps1` to check:
   - PSReadLine version is 2.4.1 (vendored)
   - Oh My Posh exists and theme path resolves
   - Fastfetch guards (NO_FASTFETCH/FASTFETCH_SHOWN)
2. In Bash, confirm `.bashrc` is present and prompt renders.
3. Validate the Oh My Posh theme JSON (optional):
   - Windows: `scripts/check-theme.ps1`
   - Linux: `scripts/check-theme.sh` (jq or Python)

## Phase 4: Troubleshoot (if needed)
- Oh My Posh not found: ensure PATH includes `%LOCALAPPDATA%/Programs/oh-my-posh/bin`
- PSReadLine not pinned: re-run `bootstrap.ps1`
- Duplicate fastfetch: set `NO_FASTFETCH=1` or rely on `FASTFETCH_SHOWN`

## Constraints
- Preserve `modules/PSReadLine/2.4.1/` and `posh-themes/jandedobbeleer.omp.json`
- Use copy semantics; back up existing configs first
- Do not commit machine-specific secrets
