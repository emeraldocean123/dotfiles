# Set paths
$obsPath    = "$env:APPDATA\obs-studio"
$docsPath   = [Environment]::GetFolderPath("MyDocuments")
$backupRoot = Join-Path $docsPath "OBS_Backups"

# Get list of backups
$backups = Get-ChildItem -Path $backupRoot -Directory | Where-Object {
    $_.Name -like "OBS_Backup_*"
} | Sort-Object LastWriteTime -Descending

if ($backups.Count -eq 0) {
    Write-Host "`n❌ No backups found in OBS_Backups."
    Read-Host "`nPress Enter to exit"
    exit
}

# Show menu
Write-Host "`n📁 Select a backup to restore:"
for ($i = 0; $i -lt $backups.Count; $i++) {
    Write-Host "[$i] $($backups[$i].Name)"
}

$choice = Read-Host "`nEnter the number of the backup to restore"
if (-not ($choice -match '^\d+$') -or [int]$choice -ge $backups.Count) {
    Write-Host "❌ Invalid selection."
    Read-Host "`nPress Enter to exit"
    exit
}

# Get selected backup path
$selectedBackup = $backups[$choice].FullName
$selectedName   = $backups[$choice].Name

Write-Host "`n📦 Restoring backup: $selectedName"

# Optional: save current config
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$preRestore = Join-Path $backupRoot "OBS_PreRestore_$timestamp"
Copy-Item -Path "$obsPath\*" -Destination $preRestore -Recurse -Force -ErrorAction SilentlyContinue

# Remove old config
Remove-Item -Path $obsPath -Recurse -Force -ErrorAction SilentlyContinue

# Restore backup contents directly into obs-studio
Copy-Item -Path "$selectedBackup\*" -Destination $obsPath -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`n✅ OBS config successfully restored to: $obsPath"
Read-Host "`nPress Enter to exit"