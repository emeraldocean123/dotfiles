param(
  [string]$ThemePath = "$HOME/Documents/dotfiles/posh-themes/jandedobbeleer.omp.json"
)
$ErrorActionPreference = 'Stop'

Write-Host "Validating Oh My Posh theme..." -ForegroundColor Cyan
if (-not (Test-Path $ThemePath)) {
  Write-Error "Theme file not found: $ThemePath"; exit 1
}
try {
  # Convert to ensure JSON is valid; output is discarded
  Get-Content -Raw -Path $ThemePath | ConvertFrom-Json | Out-Null
  $len  = (Get-Item $ThemePath).Length
  Write-Host ("Theme OK: {0} ({1} bytes)" -f $ThemePath, $len) -ForegroundColor Green
  exit 0
} catch {
  Write-Error ("Invalid JSON in theme: {0}" -f $ThemePath)
  exit 2
}
