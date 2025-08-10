param(
  [switch]$Quiet
)
$ErrorActionPreference = 'Stop'

function Write-Info($m){ if(-not $Quiet){ Write-Host $m -ForegroundColor Cyan } }
function Write-Ok($m){ if(-not $Quiet){ Write-Host $m -ForegroundColor Green } }
function Write-Warn($m){ if(-not $Quiet){ Write-Warning $m } }
function Write-Err($m){ if(-not $Quiet){ Write-Host $m -ForegroundColor Red } }

$repo = Join-Path $HOME 'Documents\dotfiles'
$profileCheck = Join-Path $repo 'powershell\Verify-Profile.ps1'
$themeCheck   = Join-Path $repo 'scripts\check-theme.ps1'

$fail = $false

Write-Info 'Running dotfiles verification...'

if (Test-Path $profileCheck) {
  try {
    pwsh -NoProfile -File $profileCheck | Out-Null
    Write-Ok 'Profile verification passed'
  } catch {
    Write-Err ("Profile verification failed: {0}" -f $_.Exception.Message)
    $fail = $true
  }
} else {
  Write-Warn "Missing: $profileCheck"
  $fail = $true
}

if (Test-Path $themeCheck) {
  try {
    pwsh -NoProfile -File $themeCheck | Out-Null
    Write-Ok 'Theme JSON validation passed'
  } catch {
    Write-Err ("Theme validation failed: {0}" -f $_.Exception.Message)
    $fail = $true
  }
} else {
  Write-Warn "Missing: $themeCheck"
  $fail = $true
}

if ($fail) { exit 1 } else { Write-Ok 'All checks passed'; exit 0 }
