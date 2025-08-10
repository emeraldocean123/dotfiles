param()
$ErrorActionPreference = 'Stop'

Write-Host "Verifying PowerShell profile..." -ForegroundColor Cyan

# Check PSReadLine version
$psrl = Get-Module -ListAvailable PSReadLine | Sort-Object Version -Descending | Select-Object -First 1
if ($psrl) {
  $ok = ($psrl.Version.ToString() -eq '2.4.1')
  Write-Host ("PSReadLine version: {0} {1}" -f $psrl.Version, ($(if($ok){'(OK)'}else{'(WARN: expected 2.4.1)'})))
} else {
  Write-Warning "PSReadLine not found"
}

# Check OMP
$omp = Get-Command oh-my-posh -ErrorAction SilentlyContinue
if ($omp) {
  Write-Host ("oh-my-posh: {0}" -f $omp.Source)
} else {
  Write-Warning "oh-my-posh not found on PATH"
}

# Theme path
$themePath = Join-Path $HOME 'Documents\dotfiles\posh-themes\jandedobbeleer.omp.json'
if (Test-Path $themePath) {
  Write-Host ("Theme exists: {0}" -f $themePath)
} else {
  Write-Warning ("Theme missing: {0}" -f $themePath)
}

# Fastfetch guards
if ($env:NO_FASTFETCH) { Write-Host "NO_FASTFETCH is set (fastfetch disabled)" -ForegroundColor Yellow }
if ($Global:FASTFETCH_SHOWN -or $env:FASTFETCH_SHOWN) { Write-Host "FASTFETCH_SHOWN guard set" -ForegroundColor DarkGray }

Write-Host "Verification complete." -ForegroundColor Green
