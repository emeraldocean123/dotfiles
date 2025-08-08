# bootstrap.ps1 — Sets up PowerShell dotfiles, profile, modules, and theme; optional auto-push to GitHub

param(
    [switch]$Force,
    [switch]$AutoPush
)

Write-Host "Starting PowerShell dotfiles setup..." -ForegroundColor Cyan

# --- Detect Environment ---
Write-Host "Detecting PowerShell environment..." -ForegroundColor Yellow
$OnWindows = $PSVersionTable.Platform -eq 'Win32NT' -or $env:OS -eq 'Windows_NT'
$OnLinux   = $PSVersionTable.Platform -eq 'Unix'
$OnMac     = $PSVersionTable.Platform -eq 'MacOS'

$PlatformName = if ($OnWindows) { 'Windows' } elseif ($OnLinux) { 'Linux' } elseif ($OnMac) { 'MacOS' } else { 'Unknown' }
Write-Host "Platform: $PlatformName"
Write-Host ("PowerShell Version: " + $PSVersionTable.PSVersion)

# --- Expected Paths ---
$DotfilesDir   = Join-Path $HOME "Documents/dotfiles"
$ProfileSource = Join-Path $DotfilesDir "powershell/Microsoft.PowerShell_profile.ps1"
$ProfileTarget = Join-Path $HOME "Documents/PowerShell/Microsoft.PowerShell_profile.ps1"
$ThemeFile     = Join-Path $DotfilesDir "posh-themes/jandedobbeleer.omp.json"

Write-Host "Expected directory structure (synced with cloud):"
Write-Host "  $DotfilesDir/"
Write-Host "  ├── bootstrap.ps1"
Write-Host "  ├── powershell/Microsoft.PowerShell_profile.ps1"
Write-Host "  └── posh-themes/jandedobbeleer.omp.json"
Write-Host "Profile will be copied to: $ProfileTarget"

# --- Verify Structure ---
Write-Host "Verifying directory structure..." -ForegroundColor Yellow
if (-not (Test-Path $ProfileSource) -or -not (Test-Path $ThemeFile)) {
    Write-Host "ERROR: Missing required files in $DotfilesDir" -ForegroundColor Red
    exit 1
}
Write-Host "Directory structure verified successfully" -ForegroundColor Green

# --- Install Required Modules ---
Write-Host "Installing required PowerShell modules..." -ForegroundColor Yellow
$modules = @("PSReadLine","Terminal-Icons","z")
foreach ($m in $modules) {
    if (Get-Module -ListAvailable -Name $m) {
        Write-Host "Module $m already installed"
    } else {
        try {
            Install-Module -Name $m -Scope CurrentUser -Force -ErrorAction Stop
            Write-Host "Installed $m"
        } catch {
            Write-Warning "Failed to install module ${m}: $($_.Exception.Message)"
        }
    }
}

# --- Ensure profile folder ---
$profileDir = Split-Path -Parent $ProfileTarget
if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }

# --- Backup Old Profile ---
$BackupDir = Join-Path $HOME ("dotfiles-backup-{0}" -f (Get-Date -Format "yyyyMMdd-HHmmss"))
New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
if (Test-Path $ProfileTarget) {
    Copy-Item $ProfileTarget $BackupDir -Force
    Write-Host "Backed up existing profile to $BackupDir" -ForegroundColor Green
}

# --- Copy New Profile ---
Copy-Item $ProfileSource $ProfileTarget -Force
Write-Host "Copied profile to $ProfileTarget" -ForegroundColor Green

# --- Optional: Auto Git Sync ---
if ($AutoPush) {
    Write-Host "`n--- Auto Git Sync Starting ---" -ForegroundColor Yellow
    git -C $DotfilesDir add .
    git -C $DotfilesDir commit -m ("Auto update {0}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) --allow-empty
    git -C $DotfilesDir push
    Write-Host "--- Auto Git Sync Complete ---`n" -ForegroundColor Green
}

Write-Host "Bootstrap complete." -ForegroundColor Cyan
