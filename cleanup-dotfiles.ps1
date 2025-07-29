# PowerShell script to clean up temporary/test files in dotfiles repository
# Follows guidelines from .github/instructions/powershell-cleanup.instructions.md

$DotfilesDir = "$env:USERPROFILE\Documents\dotfiles"
$FilesToRemove = @(
    "debug-nixos-wsl.sh",
    "NIXOS-DEBUG-WSL.sh",
    "archive/Microsoft.PowerShell_profile.complex.backup.ps1",
    "test.txt"
)

Write-Host "🔍 Starting dotfiles repository cleanup..." -ForegroundColor Cyan
Write-Host "📁 Directory: $DotfilesDir" -ForegroundColor Cyan

# Calculate initial size
$InitialSize = Get-ChildItem -Path $DotfilesDir -Recurse -File | Measure-Object -Property Length -Sum
$InitialSizeMB = [math]::Round($InitialSize.Sum / 1MB, 2)

Write-Host "📏 Initial repository size: $InitialSizeMB MB" -ForegroundColor Yellow

# Track removed files and sizes
$RemovedFiles = @()
$TotalRemovedSize = 0

# Remove files
foreach ($File in $FilesToRemove) {
    $FullPath = Join-Path $DotfilesDir $File
    if (Test-Path $FullPath) {
        try {
            $FileSize = (Get-Item $FullPath).Length
            Remove-Item -Path $FullPath -Force -ErrorAction Stop
            $RemovedFiles += $File
            $TotalRemovedSize += $FileSize
            Write-Host "🗑️ Removed: $File" -ForegroundColor Green
        } catch {
            Write-Host "⚠️ Failed to remove $File`: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "ℹ️ File not found: $File (skipping)" -ForegroundColor Yellow
    }
}

# Calculate final size
$FinalSize = Get-ChildItem -Path $DotfilesDir -Recurse -File | Measure-Object -Property Length -Sum
$FinalSizeMB = [math]::Round($FinalSize.Sum / 1MB, 2)
$SavedSizeMB = [math]::Round($TotalRemovedSize / 1MB, 2)

# Report results
Write-Host ""
Write-Host "📋 Cleanup Summary:" -ForegroundColor Cyan
if ($RemovedFiles.Count -gt 0) {
    Write-Host "✅ Removed files:" -ForegroundColor Green
    foreach ($File in $RemovedFiles) {
        Write-Host "  - $File" -ForegroundColor Green
    }
    Write-Host "📏 Space saved: $SavedSizeMB MB" -ForegroundColor Green
} else {
    Write-Host "ℹ️ No files were removed" -ForegroundColor Yellow
}
Write-Host "📏 Final repository size: $FinalSizeMB MB" -ForegroundColor Yellow
Write-Host "✨ Cleanup complete!" -ForegroundColor Green

# Update README.md or SYNC-GUIDE.md with cleanup note
$ReadmePath = Join-Path $DotfilesDir "README.md"
if (Test-Path $ReadmePath) {
    try {
        $CleanupNote = "`n## Cleanup Log`n- $(Get-Date -Format 'yyyy-MM-dd'): Removed temporary/test files ($($RemovedFiles -join ', ')). Saved $SavedSizeMB MB."
        Add-Content -Path $ReadmePath -Value $CleanupNote -ErrorAction Stop
        Write-Host "📝 Updated README.md with cleanup log" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Failed to update README.md: $($_.Exception.Message)" -ForegroundColor Red
    }
}