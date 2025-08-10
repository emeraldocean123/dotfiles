#!/usr/bin/env bash
set -euo pipefail
THEME_PATH="${1:-$HOME/Documents/dotfiles/posh-themes/jandedobbeleer.omp.json}"

echo "Validating Oh My Posh theme..."
if [[ ! -f "$THEME_PATH" ]]; then
  echo "Theme file not found: $THEME_PATH" >&2
  exit 1
fi

if command -v jq >/dev/null 2>&1; then
  jq empty "$THEME_PATH"
else
  # Fallback to python for JSON validation if jq isn't available
  python - <<'PY' "$THEME_PATH"
import json,sys
p=sys.argv[1]
json.load(open(p,'r',encoding='utf-8'))
PY
fi
size=$(wc -c <"$THEME_PATH" | tr -d ' ')
echo "Theme OK: $THEME_PATH (${size} bytes)"
