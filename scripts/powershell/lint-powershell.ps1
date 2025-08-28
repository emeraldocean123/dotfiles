param(
  [string]$Path = "$PSScriptRoot/..",
  [switch]$ExcludeVendored,
  [switch]$CI,
  [string]$Settings = "$PSScriptRoot/../PSScriptAnalyzerSettings.psd1",
  [switch]$NoSettings
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
  $paths = $paths | Where-Object {
    ($_.Replace('\\','/')) -notmatch '/modules/PSReadLine/'
  }
}

if (-not $paths) {
  Write-Host "No PowerShell files found." -ForegroundColor Yellow
  exit 0
}

$invokeParams = @{ Path = $paths; Severity = @('Information','Warning','Error'); Recurse = $true }
if (-not $NoSettings -and (Test-Path -LiteralPath $Settings)) {
  $invokeParams.Settings = $Settings
}

$issues = Invoke-ScriptAnalyzer @invokeParams

if ($CI -and $issues) {
  foreach ($i in $issues) {
    $file = if ($i.ScriptPath) { $i.ScriptPath } elseif ($i.Extent.File) { $i.Extent.File } else { '<unknown>' }
    try { $file = [System.IO.Path]::GetFullPath($file) } catch {}
    $line = $i.Extent.StartLineNumber
    $col  = $i.Extent.StartColumnNumber
    $sevRaw = $i.Severity.ToString().ToLowerInvariant()
    $sev = switch ($sevRaw) {
      'information' { 'info' }
      'warning'     { 'warning' }
      'error'       { 'error' }
      default       { 'info' }
    }
    $rule = $i.RuleName
    $msg  = $i.Message
    # Format: path:line:col: severity rule: message
    Write-Output ("{0}:{1}:{2}: {3} {4}: {5}" -f $file,$line,$col,$sev,$rule,$msg)
  }
}
if ($issues) {
  $errors = $issues | Where-Object { $_.Severity -eq 'Error' }
  if ($errors) { exit 1 } else { exit 0 }
} else { exit 0 }
