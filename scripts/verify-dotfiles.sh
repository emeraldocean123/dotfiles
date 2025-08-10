#!/usr/bin/env bash
set -euo pipefail
REPO="$HOME/Documents/dotfiles"
THEME_CHECK="$REPO/scripts/check-theme.sh"

echo "Running dotfiles verification (Linux)..."

fail=0

if [[ -x "$THEME_CHECK" ]]; then
  if ! bash "$THEME_CHECK"; then
    echo "Theme JSON validation failed" >&2
    fail=1
  else
    echo "Theme JSON validation passed"
  fi
else
  echo "Missing or non-executable: $THEME_CHECK" >&2
  fail=1
fi

# Optional: check bashrc presence (copied by bootstrap.sh)
if [[ -f "$REPO/bashrc" ]]; then
  echo "Repo bashrc exists"
else
  echo "Repo bashrc missing: $REPO/bashrc" >&2
  # Not fatal for now
fi

# Optional: oh-my-posh presence
if ! command -v oh-my-posh >/dev/null 2>&1; then
  echo "Warning: oh-my-posh not found on PATH (skip)" >&2
fi

# Optional: run PSSA lint if pwsh and module are available
if command -v pwsh >/dev/null 2>&1; then
  if pwsh -NoProfile -Command "Get-Module -ListAvailable -Name PSScriptAnalyzer | Out-Null" 2>/dev/null; then
    echo "Running PowerShell lint (PSScriptAnalyzer)..."
    if ! pwsh -NoProfile -File "$REPO/scripts/lint-powershell.ps1" -ExcludeVendored -CI; then
      echo "PSScriptAnalyzer lint found issues" >&2
      # Do not fail the overall verify on lint; CI handles exit codes
    fi
  fi
fi

exit $fail
