# Contributing

This repo contains cross-platform dotfiles and a small Nix flake.

## Formatting

- If you have Nix: `nix fmt`
- Or use the dev shell where appropriate (see nixos-config repo) — optional here

CI runs `nix fmt` on pushes/PRs and fails if formatting is required.

## Local Git hooks (optional)

Enable repo-local hooks to auto-format Nix on commit:

```
git config core.hooksPath .githooks
```

If Nix isn’t installed locally (Windows), the hook will no-op.

## PowerShell scripts

- Keep scripts idempotent and safe (no destructive defaults)
- Prefer informative output with Write-Host helpers
- Follow the vendored PSReadLine pattern (see powershell/profile.bootstrap.ps1)

## Header comment convention

Start files with a short, clear header describing purpose. Avoid path-style headers.

Example:
```
# Joseph PowerShell profile (PSReadLine 2.4.1 + Oh My Posh)
```

## PR checklist

- Format Nix: `nix fmt` (if any Nix changes)
- Keep the Oh My Posh theme single-sourced at `posh-themes/jandedobbeleer.omp.json`
- Don’t add temporary files or backups to version control
