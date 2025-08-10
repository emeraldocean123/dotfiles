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

exit $fail
