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
$IsLinuxOs   = $PSVersionTable.Platform -eq 'Unix' -and $PSVersionTable.OS -like '*Linux*'
$IsMacOSOs   = $PSVersionTable.Platform -eq 'Unix' -and $PSVersionTable.OS -like '*Darwin*'

Write-Host "Platform: $(if ($IsWindowsOs) { 'Windows' } elseif ($IsLinuxOs) { 'Linux' } elseif ($IsMacOSOs) { 'macOS' } else { 'Unknown' })" -ForegroundColor Green
Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor Green

# Set up profile and dotfiles paths
if ($CustomDotfilesDir) {
    $DotfilesDir = $CustomDotfilesDir
} elseif ($IsWindowsOs) {
    $ProfileDir  = if ($PSVersionTable.PSVersion.Major -le 5) { "$env:USERPROFILE\Documents\WindowsPowerShell" } else { "$env:USERPROFILE\Documents\PowerShell" }
    $DotfilesDir = "$env:USERPROFILE\Documents\dotfiles"
} else {
    $ProfileDir  = "$env:HOME/.config/powershell"
    $DotfilesDir = "$env:HOME/Documents/dotfiles"
}

$ProfilePath = Join-Path $ProfileDir "Microsoft.PowerShell_profile.ps1"
$BackupDir   = "$env:HOME/dotfiles-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

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
$SourceProfile = Join-Path $DotfilesDir "powershell\Microsoft.PowerShell_profile.ps1"
$ThemePath     = Join-Path $DotfilesDir "posh-themes\jandedobbeleer.omp.json"
$BootstrapPath = Join-Path $DotfilesDir "bootstrap.ps1"
$missingFiles  = @()
if (-not (Test-Path $DotfilesDir))   { $missingFiles += $DotfilesDir }
if (-not (Test-Path $SourceProfile)) { $missingFiles += $SourceProfile }
if (-not (Test-Path $ThemePath))     { $missingFiles += $ThemePath }
if (-not (Test-Path $BootstrapPath)) { $missingFiles += $BootstrapPath }

if ($missingFiles) {
    Write-Host "Error: The following required paths/files are missing:" -ForegroundColor Red
    $missingFiles | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    Write-Host "For the theme, you can download from: https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/jandedobbeleer.omp.json" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "Directory structure verified successfully" -ForegroundColor Green
}

# Ensure profile directory exists
if (-not (Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
    Write-Host "Created profile directory: $ProfileDir" -ForegroundColor Green
}

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine")

# ----------------------------------------
# 2. Install core tools
# ----------------------------------------
function Invoke-WingetInstall($id) {
    if ($IsWindowsOs -and (Get-Command winget -ErrorAction SilentlyContinue)) {
        try {
            winget install --id=$id --accept-source-agreements --accept-package-agreements --silent | Out-Null
            Write-Host "Installed/verified: $id" -ForegroundColor Green
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine")
        } catch {
            Write-Host "Failed to install $id via winget: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}

if (-not $SkipModuleInstall) {
    if ($IsWindowsOs) {
        if (-not (Get-Command git -ErrorAction SilentlyContinue))      { Invoke-WingetInstall "Git.Git" }
        if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) { Invoke-WingetInstall "JanDeDobbeleer.OhMyPosh" }
        if (-not (Get-Command fastfetch -ErrorAction SilentlyContinue)) { Invoke-WingetInstall "Fastfetch-cli.Fastfetch" }
    }

    # Install modules
    Write-Host "Installing required PowerShell modules..." -ForegroundColor Yellow
    $modules = @("PSReadLine", "Terminal-Icons", "z")
    foreach ($module in $modules) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            try {
                Install-Module -Name $module -Scope CurrentUser -Force -ErrorAction Stop
                Write-Host "Installed module: $module" -ForegroundColor Green
            } catch {
                Write-Host "Failed to install module ${module}. Error: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "Module $module already installed" -ForegroundColor Green
        }
    }
    Import-Module -Name PSReadLine,Terminal-Icons,z -Force -ErrorAction SilentlyContinue
}

# ----------------------------------------
# 3. Copy profile with backup
# ----------------------------------------
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

# ----------------------------------------
# 4. Source profile
# ----------------------------------------
if (Test-Path $ProfilePath) {
    . $ProfilePath
    Write-Host "Profile sourced successfully" -ForegroundColor Green
} else {
    Write-Host "Error: Profile file not found at $ProfilePath after copying" -ForegroundColor Red
    exit 1
}

# ----------------------------------------
# 5. GitHub SSH config
# ----------------------------------------
if ($IsWindowsOs) {
    $SshDir        = "$HOME\.ssh"
    $SshConfigPath = Join-Path $SshDir "config"
    $KeyPath       = "$HOME\.ssh\id_ed25519_github"
    $OpenSshExe    = "C:/Windows/System32/OpenSSH/ssh.exe"

    if (-not (Test-Path $SshDir)) {
        New-Item -ItemType Directory -Path $SshDir -Force | Out-Null
        Write-Host "Created: $SshDir" -ForegroundColor Green
    }

    try {
        $svc = Get-Service ssh-agent -ErrorAction Stop
        if ($svc.StartType -ne 'Automatic') { Set-Service ssh-agent -StartupType Automatic }
        if ($svc.Status -ne 'Running') { Start-Service ssh-agent }
        Write-Host "ssh-agent is running" -ForegroundColor Green
    } catch {
        Write-Host "Warning: Could not configure ssh-agent: $($_.Exception.Message)" -ForegroundColor Yellow
    }

    $configBlock = @"
Host github.com
  HostName github.com
  User git
  IdentityFile $KeyPath
  IdentitiesOnly yes
  AddKeysToAgent yes
  IdentityAgent \\\\.\\pipe\\openssh-ssh-agent
"@

    if (Test-Path $SshConfigPath) {
        $cfg = Get-Content $SshConfigPath -Raw
        if ($cfg -match "(?ms)^Host\s+github\.com\b.*?(?=^Host\s|\Z)") {
            $newCfg = [System.Text.RegularExpressions.Regex]::Replace(
                $cfg, "(?ms)^Host\s+github\.com\b.*?(?=^Host\s|\Z)", $configBlock
            )
            $newCfg | Out-File -FilePath $SshConfigPath -Encoding ascii -Force
            Write-Host "Updated github.com block" -ForegroundColor Green
        } else {
            Add-Content -Path $SshConfigPath -Value "`r`n$configBlock"
            Write-Host "Appended github.com block" -ForegroundColor Green
        }
    } else {
        $configBlock | Out-File -FilePath $SshConfigPath -Encoding ascii -Force
        Write-Host "Created ~/.ssh/config" -ForegroundColor Green
    }

    try {
        git config --global core.sshCommand $OpenSshExe | Out-Null
        Write-Host "Set git core.sshCommand" -ForegroundColor Green
    } catch {
        Write-Host "Warning: could not set git core.sshCommand" -ForegroundColor Yellow
    }

    if (Test-Path $KeyPath) {
        try {
            $list = ssh-add -l 2>$null
            if (-not ($list -match [Regex]::Escape((Get-Content "$KeyPath.pub" -ErrorAction SilentlyContinue)))) {
                ssh-add $KeyPath | Out-Null
                Write-Host "Added key: $KeyPath" -ForegroundColor Green
            } else {
                Write-Host "Key already loaded" -ForegroundColor Green
            }
        } catch {
            Write-Host "Warning: could not add key" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Note: $KeyPath not found. Generate one with:" -ForegroundColor Yellow
        Write-Host "  ssh-keygen -t ed25519 -C ""<your-email>"" -f `"$KeyPath`"" -ForegroundColor Yellow
    }
}

# ----------------------------------------
# 6. Fastfetch for SSH sessions
# ----------------------------------------
if ($env:SSH_CONNECTION -or $env:SSH_TTY) {
    if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
        try { fastfetch } catch { }
    } elseif (Get-Command winfetch -ErrorAction SilentlyContinue) {
        try { winfetch } catch { }
    }
}

# ----------------------------------------
# 7. Auto Git sync (with visible output)
# ----------------------------------------
try {
    Write-Host "`n--- Auto Git Sync Starting ---" -ForegroundColor Cyan
    Set-Location $DotfilesDir

    Write-Host "Staging changes..." -ForegroundColor Yellow
    git add -A

    Write-Host "Current status before commit:" -ForegroundColor Yellow
    git status

    $commitMessage = "Auto-update from bootstrap.ps1 ($(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))"
    Write-Host "Committing with message: $commitMessage" -ForegroundColor Yellow
    git commit -m $commitMessage --allow-empty

    Write-Host "Pushing to remote..." -ForegroundColor Yellow
    git push

    Write-Host "--- Auto Git Sync Complete ---`n" -ForegroundColor Green
} catch {
    Write-Host "Warning: Could not auto-sync to GitHub: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "Setup complete!" -ForegroundColor Green

