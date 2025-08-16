#!/usr/bin/env bash
set -euo pipefail

# cleanup-dotfiles.sh — Safe, pattern-based scan/remove tool (dry-run by default)
# Usage:
#   ./cleanup-dotfiles.sh [--delete] [--targets PATH ...]
# Notes:
#   - Default is dry-run (list what would be removed).
#   - Use --delete to actually remove files.
#   - Pass one or more paths via --targets; if none provided, script will suggest examples.

mode="dry-run" # dry-run | delete
declare -a targets=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --delete)
      mode="delete"; shift ;;
    --targets)
      shift
      while [[ $# -gt 0 && ! "$1" =~ ^-- ]]; do
        targets+=("$1"); shift
      done ;;
    -h|--help)
      echo "Usage: $0 [--delete] [--targets PATH ...]"; exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [[ ${#targets[@]} -eq 0 ]]; then
  echo "No targets provided. Examples:" >&2
  echo "  $0 --targets /etc/nixos $HOME/dotfiles $HOME/Documents/dev/dotfiles" >&2
  exit 1
fi

# Patterns considered temporary/junk per repo guidelines
read -r -d '' FIND_EXPR <<'EOF' || true
( -name '*.tmp' -o -name '*.bak' -o -name '*.old' -o -name '*~' \
  -o -name '*.swp' -o -name '*.swo' -o -name '*.orig' -o -name '*.rej' \
  -o -name '.DS_Store' -o -name 'troubleshoot-*.ps1' -o -name 'debug-*.ps1' \
  -o -name '*.FIXED.ps1' -o -name '*.MINIMAL.ps1' -o -name '*.TEST.ps1' )
EOF

total_removed_bytes=0

scan_target() {
  local t="$1"
  if [[ ! -d "$t" && ! -f "$t" ]]; then
    echo "[skip] $t (not found)"
    return 0
  fi
  echo "\n=== Scanning: $t ==="
  # Find candidates
  mapfile -d '' files < <(eval find -H "$(printf '%q' "$t")" -type f $FIND_EXPR -print0 2>/dev/null || true)
  if [[ ${#files[@]} -eq 0 ]]; then
    echo "No matches."
    return 0
  fi
  # List with sizes
  local bytes=0
  for f in "${files[@]}"; do
    # strip trailing nulls for printing
    f="${f%$'\0'}"
    if [[ -f "$f" ]]; then
      sz=$(stat -c %s "$f" 2>/dev/null || stat -f %z "$f" 2>/dev/null || echo 0)
      bytes=$((bytes + sz))
      printf "%10s  %s\n" "${sz}B" "$f"
    fi
  done | sort -h
  echo "-- subtotal: $bytes bytes"

  if [[ "$mode" == "delete" ]]; then
    echo "Removing ${#files[@]} files from $t ..."
    # Delete safely
    # shellcheck disable=SC2016
    printf '%s\0' "${files[@]}" | xargs -0r rm -f -- 2>/dev/null || true
    total_removed_bytes=$((total_removed_bytes + bytes))
  else
    echo "[dry-run] Use --delete to remove these files from $t"
  fi
}

for tgt in "${targets[@]}"; do
  scan_target "$tgt"
done

if [[ "$mode" == "delete" ]]; then
  echo "\nTotal removed: $total_removed_bytes bytes"
else
  echo "\nDry run complete. No files were removed."
fi

exit 0
