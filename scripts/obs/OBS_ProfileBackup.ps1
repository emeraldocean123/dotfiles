# Set paths
$obsPath    = "$env:APPDATA\obs-studio"
$docsPath   = [Environment]::GetFolderPath("MyDocuments")
$backupRoot = Join-Path $docsPath "OBS_Backups"

# Prompt for optional tag
$tag = Read-Host "Enter a profile tag for this backup (leave blank for default)"
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$folderName = if ($tag -ne "") {
    "OBS_Backup_${timestamp}_$tag"
} else {
    "OBS_Backup_${timestamp}"
}
$fullBackupPath = Join-Path $backupRoot $folderName

# Ensure root folder exists
if (-not (Test-Path $backupRoot)) {
    New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
}

# Create backup folder
New-Item -ItemType Directory -Path $fullBackupPath -Force | Out-Null

# Copy everything from obs-studio safely
Copy-Item -Path "$obsPath\*" -Destination $fullBackupPath -Recurse -Force -ErrorAction SilentlyContinue

# Confirmation
Write-Host "`n✅ OBS full configuration backed up to:`n$fullBackupPath"
Read-Host "`nPress Enter to exit"