param(
  [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()]
  [string]$ThemePath = "$HOME/Documents/dotfiles/posh-themes/jandedobbeleer.omp.json",
  [switch]$Quiet
)

$ErrorActionPreference = 'Stop'

function Format-Size([long]$bytes) {
  $units = 'B','KB','MB','GB','TB'
  $i = 0
  $n = [double]$bytes
  while ($n -ge 1024 -and $i -lt $units.Length-1) { $n /= 1024; $i++ }
  '{0:N1} {1}' -f $n, $units[$i]
}

if (-not $Quiet) { Write-Host "Validating Oh My Posh theme..." -ForegroundColor Cyan }

if (-not (Test-Path -LiteralPath $ThemePath)) {
  Write-Error "Theme file not found: $ThemePath"; exit 1
}

# Light sanity checks on filename
$ext = [IO.Path]::GetExtension($ThemePath)
if ($ext -ne '.json' -and -not $Quiet) { Write-Warning "Theme isn't a .json file: $ThemePath" }
if ($ThemePath -match '\\.bak$' -and -not $Quiet) { Write-Warning "Validating a .bak file (is this intended?): $ThemePath" }

try {
  # Convert to ensure JSON is valid; output is discarded
  $null = Get-Content -Raw -Path $ThemePath | ConvertFrom-Json -AsHashtable
  $len  = (Get-Item -LiteralPath $ThemePath).Length
  $size = Format-Size $len
  if (-not $Quiet) {
    Write-Host ("Theme OK: {0} ({1}, {2} bytes)" -f $ThemePath, $size, $len) -ForegroundColor Green
  }
  exit 0
} catch {
  $msg = $_.Exception.Message
  Write-Error ("Invalid JSON in theme: {0} — {1}" -f $ThemePath, $msg)
  exit 2
}
