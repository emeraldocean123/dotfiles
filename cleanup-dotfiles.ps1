<#
.SYNOPSIS
    Cleans up temporary, backup, and debug files in the dotfiles repository safely.

.DESCRIPTION
    Pattern-based cleanup following .github/instructions/powershell-cleanup.instructions.md.
    Dry-run by default. Use -Apply to actually delete. Generates a log file under .logs.

.EXAMPLE
    ./cleanup-dotfiles.ps1                 # Dry-run, show what would be deleted
    ./cleanup-dotfiles.ps1 -Apply          # Delete matching files with confirmation
    ./cleanup-dotfiles.ps1 -Apply -Force   # Delete without prompting
    ./cleanup-dotfiles.ps1 -Include "*.log" # Add extra patterns
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$Apply,
    [switch]$Force,
    [string[]]$Include
)

$ErrorActionPreference = 'Stop'

$RepoRoot = Join-Path $env:USERPROFILE 'Documents/dotfiles'
if (-not (Test-Path $RepoRoot)) { throw "Repo not found: $RepoRoot" }

$LogDir = Join-Path $RepoRoot '.logs'
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
$LogPath = Join-Path $LogDir ("cleanup-{0}.log" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))

Write-Host "🔍 Dotfiles cleanup" -ForegroundColor Cyan
Write-Host "📁 Repo: $RepoRoot" -ForegroundColor Cyan
Write-Host ("Mode: {0}" -f ($Apply ? 'APPLY' : 'DRY-RUN')) -ForegroundColor Yellow
"# Cleanup run: $(Get-Date -Format o)  Mode=$($Apply ? 'APPLY' : 'DRY-RUN')" | Out-File -FilePath $LogPath -Encoding utf8 -Force

# Default patterns from instructions
$DefaultPatterns = @(
    '*.FIXED.ps1','*.MINIMAL.ps1','*.TEST.ps1',
    'troubleshoot-*.ps1','debug-*.ps1','*debug*','*troubleshoot*',
    '*.tmp','*.bak','*.old'
)
if ($Include) { $DefaultPatterns += $Include }

# Exclusions: keep important areas
$ExcludeDirs = @('.git','.github','.githooks','modules/PSReadLine')
$ExcludeFiles = @('powershell/Microsoft.PowerShell_profile.ps1','powershell/profile.bootstrap.ps1','cleanup-dotfiles.ps1','README.md','SYNC-GUIDE.md','flake.nix','flake.lock')

function Test-IsExcluded($Path) {
    $rel = Resolve-Path -LiteralPath $Path | ForEach-Object { $_.Path }
    $rel = $rel.Replace([IO.Path]::DirectorySeparatorChar, '/')
    foreach ($d in $ExcludeDirs) { if ($rel -match "/$([regex]::Escape($d))(\/|$)") { return $true } }
    foreach ($f in $ExcludeFiles) { if ($rel -like "*/$f") { return $true } }
    return $false
}

function Get-RelPath([string]$full){
    $rel = $full.Substring($RepoRoot.Length)
    # Remove any leading \ or /
    return ($rel -replace '^[\\/]+','')
}

function Get-RepoSizeMB($root){
    $m = Get-ChildItem -Path $root -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
    [math]::Round(($m.Sum / 1MB),2)
}

$initialMB = Get-RepoSizeMB $RepoRoot
Write-Host "� Initial size: $initialMB MB" -ForegroundColor Yellow

$Candidates = @()
foreach ($pat in $DefaultPatterns) {
    $found = Get-ChildItem -Path $RepoRoot -Recurse -File -Filter $pat -ErrorAction SilentlyContinue
    foreach ($f in $found) {
        if (-not (Test-IsExcluded $f.FullName)) { $Candidates += $f }
    }
}

# De-duplicate candidates
$Candidates = $Candidates | Sort-Object FullName -Unique

if (-not $Candidates) {
    Write-Host "ℹ️ No matching files found." -ForegroundColor Yellow
    "No matches." | Add-Content -Path $LogPath
    return
}

Write-Host "� Matches:" -ForegroundColor Cyan
foreach ($c in $Candidates) {
    $rel = Get-RelPath $c.FullName
    $sz = [math]::Round(($c.Length/1KB),1)
    Write-Host ("  - {0} ({1} KB)" -f $rel, $sz) -ForegroundColor Gray
}

"Matches:" | Add-Content -Path $LogPath
$Candidates | ForEach-Object { ("{0},{1}" -f (Get-RelPath $_.FullName),$_.Length) } | Add-Content -Path $LogPath

$removed = 0L; $removedBytes = 0L
if ($Apply) {
    foreach ($c in $Candidates) {
    $rel = Get-RelPath $c.FullName
        if ($PSCmdlet.ShouldProcess($c.FullName, 'Remove')) {
            try {
                $len = $c.Length
                Remove-Item -LiteralPath $c.FullName -Force -ErrorAction Stop -Confirm:(!$Force)
                $removed += 1; $removedBytes += $len
                Write-Host ("🗑️ Removed: {0}" -f $rel) -ForegroundColor Green
                ("Removed: {0},{1}" -f $rel,$len) | Add-Content -Path $LogPath
            } catch {
                Write-Host ("⚠️ Failed: {0} -> {1}" -f $rel, $_.Exception.Message) -ForegroundColor Red
                ("Failed: {0},{1}" -f $rel, $_.Exception.Message) | Add-Content -Path $LogPath
            }
        }
    }
} else {
    Write-Host "This is a DRY-RUN. Use -Apply to delete files." -ForegroundColor Yellow
}

$finalMB = Get-RepoSizeMB $RepoRoot
$savedMB = if ($Apply) { [math]::Round(($removedBytes/1MB),2) } else { 0 }
Write-Host ""; Write-Host "📊 Summary" -ForegroundColor Cyan
Write-Host ("  Matches: {0}" -f $Candidates.Count)
Write-Host ("  Removed: {0}" -f $removed)
Write-Host ("  Saved: {0} MB" -f $savedMB)
Write-Host ("  Size: {0} -> {1} MB" -f $initialMB,$finalMB)
("Summary: matches={0} removed={1} savedMB={2} sizeMB={3}->{4}" -f $Candidates.Count,$removed,$savedMB,$initialMB,$finalMB) | Add-Content -Path $LogPath
Write-Host ("Log: {0}" -f $LogPath) -ForegroundColor DarkGray