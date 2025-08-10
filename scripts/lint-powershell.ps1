param(
  [string]$Path = "$PSScriptRoot/..",
  [switch]$ExcludeVendored
)
$ErrorActionPreference = 'Stop'

Write-Host "Linting PowerShell scripts..." -ForegroundColor Cyan

if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
  Write-Warning "PSScriptAnalyzer not found. Install with: Install-Module PSScriptAnalyzer -Scope CurrentUser"
  exit 0
}

Import-Module PSScriptAnalyzer -ErrorAction Stop

$paths = Get-ChildItem -Path $Path -Recurse -Include *.ps1,*.psm1 -File | Select-Object -ExpandProperty FullName
if ($ExcludeVendored) {
  $paths = $paths | Where-Object { $_ -notmatch "modules\\PSReadLine\\" }
}

if (-not $paths) {
  Write-Host "No PowerShell files found." -ForegroundColor Yellow
  exit 0
}

$issues = Invoke-ScriptAnalyzer -Path $paths -Severity @('Information','Warning','Error') -Recurse -ReportSummary
if ($issues) {
  $errors = $issues | Where-Object { $_.Severity -eq 'Error' }
  if ($errors) { exit 1 } else { exit 0 }
} else { exit 0 }
