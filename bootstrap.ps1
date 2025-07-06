# 🚀 Joseph's PowerShell Bootstrap Script
# Cross-platform PowerShell setup for Windows and Linux

param(
    [switch]$SkipModuleInstall,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

Write-Host "🔧 Starting PowerShell dotfiles setup..." -ForegroundColor Cyan

# ----------------------------------------
# 1. Detect environment and setup paths
# ----------------------------------------
Write-Host "🧠 Detecting PowerShell environment..." -ForegroundColor Yellow

$IsWindowsOs = $PSVersionTable.PSVersion.Major -ge 6 ? $IsWindows : ($env:OS -eq "Windows_NT")
$IsLinuxOs = $PSVersionTable.PSVersion.Major -ge 6 ? $IsLinux : $false
$IsMacOSOs = $PSVersionTable.PSVersion.Major -ge 6 ? $IsMacOS : $false

Write-Host "💻 Platform: $(if ($IsWindowsOs) { 'Windows' } elseif ($IsLinuxOs) { 'Linux' } elseif ($IsMacOSOs) { 'macOS' } else { 'Unknown' })" -ForegroundColor Green

# Set up profile paths
if ($IsWindowsOs) {
    $ProfileDir = [Environment]::GetFolderPath("MyDocuments") + "\PowerShell"
    $DotfilesDir = "$env:USERPROFILE\dotfiles"
} else {
    $ProfileDir = "$env:HOME/.config/powershell"
    $DotfilesDir = "$env:HOME/dotfiles"
}

$ProfilePath = Join-Path $ProfileDir "Microsoft.PowerShell_profile.ps1"
$BackupDir = "$env:HOME/dotfiles-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

Write-Host "📁 Profile directory: $ProfileDir" -ForegroundColor Magenta
Write-Host "📁 Dotfiles directory: $DotfilesDir" -ForegroundColor Magenta

# ----------------------------------------
# 2. Setup dotfiles repository
# ----------------------------------------
Write-Host "📁 Setting up dotfiles repository..." -ForegroundColor Yellow

if (-not (Test-Path $DotfilesDir)) {
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Write-Host "📥 Cloning dotfiles repository..." -ForegroundColor Blue
        git clone https://github.com/emeraldocean123/dotfiles.git $DotfilesDir
    } else {
        Write-Error "❌ Git not found. Please install Git or manually clone dotfiles to $DotfilesDir"
    }
} else {
    Write-Host "✅ Dotfiles directory already exists" -ForegroundColor Green
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Push-Location $DotfilesDir
        Write-Host "🔄 Pulling latest changes..." -ForegroundColor Blue
        try { git pull origin main } catch { Write-Warning "⚠️ Could not pull latest changes" }
        Pop-Location
    }
}

# ----------------------------------------
# 3. Create PowerShell profile directory
# ----------------------------------------
Write-Host "📂 Creating PowerShell profile directory..." -ForegroundColor Yellow

if (-not (Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
    Write-Host "✅ Created profile directory: $ProfileDir" -ForegroundColor Green
}

# ----------------------------------------
# 4. Backup existing profile and create symlink
# ----------------------------------------
Write-Host "🔗 Setting up PowerShell profile link..." -ForegroundColor Yellow

$PowerShellProfileSource = Join-Path $DotfilesDir "powershell\Microsoft.PowerShell_profile.ps1"

if (Test-Path $PowerShellProfileSource) {
    # Create backup directory
    if (-not (Test-Path $BackupDir)) {
        New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
        Write-Host "📁 Created backup directory: $BackupDir" -ForegroundColor Cyan
    }
    
    # Backup existing profile if it exists
    if (Test-Path $ProfilePath) {
        Write-Host "📋 Backing up existing PowerShell profile..." -ForegroundColor Yellow
        Copy-Item -Path $ProfilePath -Destination (Join-Path $BackupDir "Microsoft.PowerShell_profile.ps1") -Force
    }
    
    # Create symbolic link (requires admin on Windows)
    try {
        if ($IsWindowsOs) {
            # On Windows, try to create symbolic link (requires admin) or hard link
            try {
                New-Item -ItemType SymbolicLink -Path $ProfilePath -Target $PowerShellProfileSource -Force | Out-Null
                Write-Host "🔗 Created symbolic link: $ProfilePath -> $PowerShellProfileSource" -ForegroundColor Green
            } catch {
                # Fall back to copying file
                Copy-Item -Path $PowerShellProfileSource -Destination $ProfilePath -Force
                Write-Host "📄 Copied PowerShell profile (symbolic link requires admin privileges)" -ForegroundColor Yellow
            }
        } else {
            # On Linux/macOS, symbolic links work without admin
            if (Test-Path $ProfilePath) { Remove-Item $ProfilePath -Force }
            New-Item -ItemType SymbolicLink -Path $ProfilePath -Target $PowerShellProfileSource -Force | Out-Null
            Write-Host "🔗 Created symbolic link: $ProfilePath -> $PowerShellProfileSource" -ForegroundColor Green
        }
    } catch {
        Write-Error "❌ Failed to create profile link: $_"
    }
} else {
    Write-Warning "⚠️ PowerShell profile source not found: $PowerShellProfileSource"
}

# ----------------------------------------
# 5. Install essential PowerShell modules (optional)
# ----------------------------------------
if (-not $SkipModuleInstall) {
    Write-Host "📦 Installing essential PowerShell modules..." -ForegroundColor Yellow
    
    $Modules = @(
        "PSReadLine",
        "Terminal-Icons", 
        "z",
        "PSFzf"
    )
    
    foreach ($Module in $Modules) {
        try {
            if (-not (Get-Module -ListAvailable -Name $Module)) {
                Write-Host "📥 Installing module: $Module" -ForegroundColor Blue
                Install-Module -Name $Module -Scope CurrentUser -Force -AcceptLicense
                Write-Host "✅ Installed: $Module" -ForegroundColor Green
            } else {
                Write-Host "✅ Module already installed: $Module" -ForegroundColor Green
            }
        } catch {
            Write-Warning "⚠️ Failed to install module $Module`: $_"
        }
    }
} else {
    Write-Host "📦 Skipping module installation (use -SkipModuleInstall to enable)" -ForegroundColor Yellow
}

# ----------------------------------------
# 6. Final verification and summary
# ----------------------------------------
Write-Host ""
Write-Host "✨ PowerShell bootstrap complete!" -ForegroundColor Green
Write-Host "🔄 PowerShell profile configured and ready" -ForegroundColor Cyan
Write-Host "📦 Backups saved to: $BackupDir" -ForegroundColor Magenta

Write-Host ""
Write-Host "💙 PowerShell Configuration:" -ForegroundColor Blue
if (Test-Path $ProfilePath) {
    Write-Host "✅ Profile linked: $ProfilePath" -ForegroundColor Green
} else {
    Write-Host "❌ Profile not found: $ProfilePath" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎯 Next steps:" -ForegroundColor Cyan
Write-Host "  • Restart PowerShell or run: . `$PROFILE" -ForegroundColor White
Write-Host "  • Test with: Get-Command Get-*" -ForegroundColor White
if ($IsWindowsOs) {
    Write-Host "  • For symbolic links: Run as Administrator next time" -ForegroundColor White
}

Write-Host ""
Write-Host "🎉 Your PowerShell environment is ready!" -ForegroundColor Green
