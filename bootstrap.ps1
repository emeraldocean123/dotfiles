param(
    [switch]$SkipModuleInstall,
    [switch]$Force,
    [string]$CustomDotfilesDir
)

$ErrorActionPreference = "Stop"

Write-Host "Starting PowerShell dotfiles setup..." -ForegroundColor Cyan

# ----------------------------------------
# 1. Detect environment and setup paths
# ----------------------------------------
Write-Host "Detecting PowerShell environment..." -ForegroundColor Yellow

$IsWindowsOs = $PSVersionTable.Platform -eq 'Win32NT' -or $env:OS -eq 'Windows_NT'
$IsLinuxOs = $PSVersionTable.Platform -eq 'Unix' -and $PSVersionTable.OS -like '*Linux*'
$IsMacOSOs = $PSVersionTable.Platform -eq 'Unix' -and $PSVersionTable.OS -like '*Darwin*'

Write-Host "Platform: $(if ($IsWindowsOs) { 'Windows' } elseif ($IsLinuxOs) { 'Linux' } elseif ($IsMacOSOs) { 'macOS' } else { 'Unknown' })" -ForegroundColor Green
Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor Green

# Set up profile and dotfiles paths
if ($CustomDotfilesDir) {
    $DotfilesDir = $CustomDotfilesDir
} elseif ($IsWindowsOs) {
    $ProfileDir = if ($PSVersionTable.PSVersion.Major -le 5) { "$env:USERPROFILE\Documents\WindowsPowerShell" } else { "$env:USERPROFILE\Documents\PowerShell" }
    $DotfilesDir = "$env:USERPROFILE\Documents\dotfiles"
} else {
    $ProfileDir = "$env:HOME/.config/powershell"
    $DotfilesDir = "$env:HOME/Documents/dotfiles"
}

$ProfilePath = Join-Path $ProfileDir "Microsoft.PowerShell_profile.ps1"
$BackupDir = "$env:HOME/dotfiles-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

# Display expected directory structure
Write-Host "Expected directory structure (synced with Google Drive):" -ForegroundColor Cyan
Write-Host "  $DotfilesDir/" -ForegroundColor Cyan
Write-Host "  ├── bootstrap.ps1                    # This setup script" -ForegroundColor Cyan
Write-Host "  ├── powershell/" -ForegroundColor Cyan
Write-Host "  │   └── Microsoft.PowerShell_profile.ps1  # PowerShell profile script" -ForegroundColor Cyan
Write-Host "  └── posh-themes/" -ForegroundColor Cyan
Write-Host "      └── jandedobbeleer.omp.json      # Oh My Posh theme file" -ForegroundColor Cyan
Write-Host "Profile will be copied to: $ProfilePath" -ForegroundColor Cyan
Write-Host "Ensure '$DotfilesDir' is synced with Google Drive for cross-device consistency." -ForegroundColor Cyan

# Verify directory structure
Write-Host "Verifying directory structure..." -ForegroundColor Yellow
if (-not (Test-Path $DotfilesDir)) {
    Write-Host "Error: Dotfiles directory '$DotfilesDir' does not exist. Please create it or use -CustomDotfilesDir." -ForegroundColor Red
    Write-Host "Run: New-Item -ItemType Directory -Path '$DotfilesDir' -Force" -ForegroundColor Yellow
    exit 1
}

$SourceProfile = Join-Path $DotfilesDir "powershell\Microsoft.PowerShell_profile.ps1"
$ThemePath = Join-Path $DotfilesDir "posh-themes\jandedobbeleer.omp.json"
$BootstrapPath = Join-Path $DotfilesDir "bootstrap.ps1"
$missingFiles = @()
if (-not (Test-Path $SourceProfile)) {
    $missingFiles += $SourceProfile
}
if (-not (Test-Path $ThemePath)) {
    $missingFiles += $ThemePath
}
if (-not (Test-Path $BootstrapPath)) {
    $missingFiles += $BootstrapPath
}
if ($missingFiles) {
    Write-Host "Error: The following required files are missing:" -ForegroundColor Red
    foreach ($file in $missingFiles) {
        Write-Host "  - $file" -ForegroundColor Red
    }
    Write-Host "Please ensure these files exist in '$DotfilesDir' with the structure shown above." -ForegroundColor Red
    Write-Host "For the theme, download from: https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/jandedobbeleer.omp.json" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "Directory structure verified successfully" -ForegroundColor Green
}

# Ensure profile directory exists
if (-not (Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
    Write-Host "Created profile directory: $ProfileDir" -ForegroundColor Green
}

# Refresh PATH to ensure newly installed tools are available
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine")

# Install Git via winget (Windows)
if (-not $SkipModuleInstall -and -not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Git..." -ForegroundColor Yellow
    if ($IsWindowsOs) {
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            try {
                winget install Git.Git --accept-source-agreements --accept-package-agreements
                Write-Host "Installed Git via winget" -ForegroundColor Green
                # Refresh PATH again
                $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine")
            } catch {
                Write-Host "Failed to install Git via winget. Error: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host "Manually install from: https://git-scm.com/download/win" -ForegroundColor Yellow
            }
        } else {
            Write-Host "Warning: winget not found. Please install winget or manually install Git from: https://git-scm.com/download/win" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Warning: Git installation not supported on this platform. Follow instructions at: https://git-scm.com/downloads" -ForegroundColor Yellow
    }
}

# Install Oh My Posh via winget (Windows)
if (-not $SkipModuleInstall -and -not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Oh My Posh..." -ForegroundColor Yellow
    if ($IsWindowsOs) {
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            try {
                winget install JanDeDobbeleer.OhMyPosh --accept-source-agreements --accept-package-agreements
                Write-Host "Installed Oh My Posh via winget" -ForegroundColor Green
                # Refresh PATH again
                $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine")
            } catch {
                Write-Host "Failed to install Oh My Posh via winget. Error: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host "Manually install from: https://ohmyposh.dev/docs/installation/windows" -ForegroundColor Yellow
            }
        } else {
            Write-Host "Warning: winget not found. Please install winget or manually install Oh My Posh from: https://ohmyposh.dev/docs/installation/windows" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Warning: Oh My Posh installation not supported on this platform. Follow instructions at: https://ohmyposh.dev/docs/installation" -ForegroundColor Yellow
    }
}

# Install other required modules
if (-not $SkipModuleInstall) {
    Write-Host "Installing required PowerShell modules..." -ForegroundColor Yellow
    $modules = @("PSReadLine", "Terminal-Icons", "z")
    foreach ($module in $modules) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            try {
                Install-Module -Name $module -Scope CurrentUser -Force -ErrorAction Stop
                Write-Host "Installed module: $module" -ForegroundColor Green
            } catch {
                Write-Host "Failed to install module $module. Error: $($_.Exception.Message)" -ForegroundColor Red
            }
        } else {
            Write-Host "Module $module already installed" -ForegroundColor Green
        }
    }
    # Refresh module path
    Import-Module -Name PSReadLine,Terminal-Icons,z -Force -ErrorAction SilentlyContinue
}

# Copy profile
try {
    if (Test-Path $SourceProfile) {
        if ((Test-Path $ProfilePath) -and -not $Force) {
            Write-Host "Profile exists at $ProfilePath. Use -Force to overwrite." -ForegroundColor Yellow
        } else {
            if (Test-Path $ProfilePath) {
                New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
                Copy-Item -Path $ProfilePath -Destination $BackupDir -Force
                Write-Host "Backed up existing profile to $BackupDir" -ForegroundColor Green
            }
            Copy-Item -Path $SourceProfile -Destination $ProfilePath -Force
            Write-Host "Copied profile to $ProfilePath" -ForegroundColor Green
        }
    } else {
        Write-Host "Error: Source profile not found at $SourceProfile" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Error copying profile: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Source the profile
if (Test-Path $ProfilePath) {
    . $ProfilePath
    Write-Host "Profile sourced successfully" -ForegroundColor Green
} else {
    Write-Host "Error: Profile file not found at $ProfilePath after copying" -ForegroundColor Red
    exit 1
}

Write-Host "Note: Some changes (e.g., module imports) may require a new PowerShell session. Run 'powershell' or restart your terminal." -ForegroundColor Cyan
Write-Host "Setup complete! Verify aliases (e.g., 'll', 'gs') and the prompt in a new session." -ForegroundColor Green
Write-Host "If Git aliases are missing, install Git from: https://git-scm.com/download/win" -ForegroundColor Cyan
Write-Host "If Oh My Posh prompt is missing, ensure winget is installed and run 'winget install JanDeDobbeleer.OhMyPosh'" -ForegroundColor Cyan