param(
    [switch]$SkipModuleInstall,
    [switch]$Force,
    [switch]$AutoPush,
    [string]$CustomDotfilesDir
)

$ErrorActionPreference = "Stop"

Write-Host "Starting PowerShell dotfiles setup..." -ForegroundColor Cyan

# ----------------------------------------
# 1) Detect environment & set paths
# ----------------------------------------
Write-Host "Detecting PowerShell environment..." -ForegroundColor Yellow

$IsWindowsOs = $PSVersionTable.Platform -eq 'Win32NT' -or $env:OS -eq 'Windows_NT'
$IsLinuxOs   = $PSVersionTable.Platform -eq 'Unix' -and $PSVersionTable.OS -like '*Linux*'
$IsMacOSOs   = $PSVersionTable.Platform -eq 'Unix' -and $PSVersionTable.OS -like '*Darwin*'

Write-Host ("Platform: " + (if ($IsWindowsOs) { 'Windows' } elseif ($IsLinuxOs) { 'Linux' } elseif ($IsMacOSOs) { 'macOS' } else { 'Unknown' })) -ForegroundColor Green
Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor Green

# Resolve dotfiles/profile locations
if ($CustomDotfilesDir) {
    $DotfilesDir = $CustomDotfilesDir
} elseif ($IsWindowsOs) {
    $ProfileDir  = if ($PSVersionTable.PSVersion.Major -le 5) { "$env:USERPROFILE\Documents\WindowsPowerShell" } else { "$env:USERPROFILE\Documents\PowerShell" }
    $DotfilesDir = "$env:USERPROFILE\Documents\dotfiles"
} else {
    $ProfileDir  = "$env:HOME/.config/powershell"
    $DotfilesDir = "$env:HOME/Documents/dotfiles"
}

$ProfileDir  = $ProfileDir ?? (if ($IsWindowsOs) { "$env:USERPROFILE\Documents\PowerShell" } else { "$env:HOME/.config/powershell" })
$ProfilePath = Join-Path $ProfileDir "Microsoft.PowerShell_profile.ps1"
$BackupDir   = "$env:HOME/dotfiles-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

# ----------------------------------------
# 2) Show & verify expected structure
# ----------------------------------------
Write-Host "Expected directory structure (synced with Google Drive):" -ForegroundColor Cyan
Write-Host "  $DotfilesDir/" -ForegroundColor Cyan
Write-Host "  ├── bootstrap.ps1                    # This setup script" -ForegroundColor Cyan
Write-Host "  ├── powershell/" -ForegroundColor Cyan
Write-Host "  │   └── Microsoft.PowerShell_profile.ps1  # PowerShell profile script" -ForegroundColor Cyan
Write-Host "  └── posh-themes/" -ForegroundColor Cyan
Write-Host "      └── jandedobbeleer.omp.json      # Oh My Posh theme file" -ForegroundColor Cyan
Write-Host "Profile will be copied to: $ProfilePath" -ForegroundColor Cyan
Write-Host "Ensure '$DotfilesDir' is synced with Google Drive for cross-device consistency." -ForegroundColor Cyan

Write-Host "Verifying directory structure..." -ForegroundColor Yellow
$SourceProfile = Join-Path $DotfilesDir "powershell\Microsoft.PowerShell_profile.ps1"
$ThemePath     = Join-Path $DotfilesDir "posh-themes\jandedobbeleer.omp.json"
$BootstrapPath = Join-Path $DotfilesDir "bootstrap.ps1"

$missing = @()
if (-not (Test-Path $DotfilesDir))   { $missing += $DotfilesDir }
if (-not (Test-Path $SourceProfile)) { $missing += $SourceProfile }
if (-not (Test-Path $ThemePath))     { $missing += $ThemePath }
if (-not (Test-Path $BootstrapPath)) { $missing += $BootstrapPath }

if ($missing.Count -gt 0) {
    Write-Host "Error: The following required paths/files are missing:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    Write-Host "For the theme, you can download from:" -ForegroundColor Yellow
    Write-Host "  https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/jandedobbeleer.omp.json" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "Directory structure verified successfully" -ForegroundColor Green
}

# Ensure profile dir exists
if (-not (Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
    Write-Host "Created profile directory: $ProfileDir" -ForegroundColor Green
}

# Refresh PATH (include WinGet Links so fresh installs work immediately)
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path","Machine")
$wingetLinks = "$env:LOCALAPPDATA\Microsoft\WinGet\Links"
if ($IsWindowsOs -and (Test-Path $wingetLinks) -and ($env:Path -split ';' -notcontains $wingetLinks)) {
    $env:Path = "$env:Path;$wingetLinks"
}

# ----------------------------------------
# 3) Install core tools (Windows via winget)
# ----------------------------------------
function Invoke-WingetInstall($id) {
    if ($IsWindowsOs -and (Get-Command winget -ErrorAction SilentlyContinue)) {
        try {
            winget install --id=$id --accept-source-agreements --accept-package-agreements --silent | Out-Null
            Write-Host "Installed/verified: $id" -ForegroundColor Green
            # refresh PATH after install
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path","Machine")
            if ((Test-Path $wingetLinks) -and ($env:Path -split ';' -notcontains $wingetLinks)) {
                $env:Path = "$env:Path;$wingetLinks"
            }
        } catch {
            Write-Host ("Failed to install {0} via winget: {1}" -f $id, $_.Exception.Message) -ForegroundColor Yellow
        }
    }
}

if (-not $SkipModuleInstall) {
    if ($IsWindowsOs) {
        if (-not (Get-Command git -ErrorAction SilentlyContinue))         { Invoke-WingetInstall "Git.Git" }
        if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue))  { Invoke-WingetInstall "JanDeDobbeleer.OhMyPosh" }
        if (-not (Get-Command fastfetch -ErrorAction SilentlyContinue))   { Invoke-WingetInstall "Fastfetch-cli.Fastfetch" }
    }

    # PowerShell modules (all platforms)
    Write-Host "Installing required PowerShell modules..." -ForegroundColor Yellow
    $modules = @("PSReadLine","Terminal-Icons","z")
    foreach ($module in $modules) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            try {
                Install-Module -Name $module -Scope CurrentUser -Force -ErrorAction Stop
                Write-Host "Installed module: $module" -ForegroundColor Green
            } catch {
                Write-Host ("Failed to install module {0}. Error: {1}" -f $module, $_.Exception.Message) -ForegroundColor Yellow
            }
        } else {
            Write-Host "Module $module already installed" -ForegroundColor Green
        }
    }
    Import-Module -Name PSReadLine,Terminal-Icons,z -Force -ErrorAction SilentlyContinue
}

# ----------------------------------------
# 4) Copy profile (with backup)
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
    Write-Host ("Error copying profile: {0}" -f $_.Exception.Message) -ForegroundColor Red
    exit 1
}

# ----------------------------------------
# 5) Source profile
# ----------------------------------------
if (Test-Path $ProfilePath) {
    . $ProfilePath
    Write-Host "Profile sourced successfully" -ForegroundColor Green
} else {
    Write-Host "Error: Profile file not found at $ProfilePath after copying" -ForegroundColor Red
    exit 1
}

# ----------------------------------------
# 6) GitHub SSH config (Windows)
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

    # Ensure ssh-agent is automatic & running
    try {
        $svc = Get-Service ssh-agent -ErrorAction Stop
        if ($svc.StartType -ne 'Automatic') { Set-Service ssh-agent -StartupType Automatic }
        if ($svc.Status -ne 'Running')      { Start-Service ssh-agent }
        Write-Host "ssh-agent is running (StartupType=Automatic)" -ForegroundColor Green
    } catch {
        Write-Host ("Warning: Could not configure ssh-agent service: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
    }

    # Upsert github.com block in ~/.ssh/config
    $configBlock = @"
Host github.com
  HostName github.com
  User git
  IdentityFile $KeyPath
  IdentitiesOnly yes
  AddKeysToAgent yes
  IdentityAgent \\.\pipe\openssh-ssh-agent
"@

    if (Test-Path $SshConfigPath) {
        $cfg = Get-Content $SshConfigPath -Raw
        if ($cfg -match "(?ms)^Host\s+github\.com\b.*?(?=^Host\s|\Z)") {
            $newCfg = [System.Text.RegularExpressions.Regex]::Replace(
                $cfg, "(?ms)^Host\s+github\.com\b.*?(?=^Host\s|\Z)", $configBlock
            )
            $newCfg | Out-File -FilePath $SshConfigPath -Encoding ascii -Force
            Write-Host "Updated github.com block in ~/.ssh/config" -ForegroundColor Green
        } else {
            Add-Content -Path $SshConfigPath -Value "`r`n$configBlock"
            Write-Host "Appended github.com block to ~/.ssh/config" -ForegroundColor Green
        }
    } else {
        $configBlock | Out-File -FilePath $SshConfigPath -Encoding ascii -Force
        Write-Host "Created ~/.ssh/config" -ForegroundColor Green
    }

    # Use Windows OpenSSH (let ~/.ssh/config choose the key)
    try {
        git config --global core.sshCommand $OpenSshExe | Out-Null
        Write-Host "Set git core.sshCommand -> $OpenSshExe" -ForegroundColor Green
    } catch {
        Write-Host ("Warning: could not set git core.sshCommand: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
    }

    # Add key to agent if present
    if (Test-Path $KeyPath) {
        try {
            $agentList = ssh-add -l 2>$null
            $pub = Get-Content "$KeyPath.pub" -ErrorAction SilentlyContinue
            if ($pub -and ($agentList -notmatch [Regex]::Escape($pub))) {
                ssh-add $KeyPath | Out-Null
                Write-Host "Added key to agent: $KeyPath" -ForegroundColor Green
            } else {
                Write-Host "Key already loaded in agent (or no pub found)" -ForegroundColor Green
            }
        } catch {
            Write-Host ("Warning: could not add key to agent: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
        }
    } else {
        Write-Host "Note: $KeyPath not found. Generate one with:" -ForegroundColor Yellow
        Write-Host "  ssh-keygen -t ed25519 -C ""<your-email>"" -f `"$KeyPath`"" -ForegroundColor Yellow
        Write-Host "Then: ssh-add `"$KeyPath`", copy .pub to GitHub, and re-run this script." -ForegroundColor Yellow
    }
}

# ----------------------------------------
# 7) Fastfetch/Winfetch banner for SSH-like sessions
# ----------------------------------------
if ($env:SSH_CONNECTION -or $env:SSH_TTY) {
    if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
        try { fastfetch } catch { }
    } elseif (Get-Command winfetch -ErrorAction SilentlyContinue) {
        try { winfetch } catch { }
    }
}

# ----------------------------------------
# 8) Optional: Auto-commit & push this repo
# ----------------------------------------
if ($AutoPush) {
    try {
        if (Test-Path $DotfilesDir) {
            Set-Location $DotfilesDir
            if (Test-Path ".git") {
                git add -A
                $msg = "bootstrap sync: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
                git commit -m $msg 2>$null | Out-Null
                git push
                Write-Host "AutoPush: pushed dotfiles to origin." -ForegroundColor Green
            } else {
                Write-Host "AutoPush skipped: not a git repo at $DotfilesDir" -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host ("AutoPush failed: {0}" -f $_.Exception.Message) -ForegroundColor Yellow
    } finally {
        # go back to original location if needed
        try { Pop-Location } catch { }
    }
}

# ----------------------------------------
# 9) Done
# ----------------------------------------
Write-Host "Note: Some changes may require a new PowerShell session." -ForegroundColor Cyan
Write-Host "Setup complete! Verify aliases (e.g., 'll', 'gs') and the prompt in a new session." -ForegroundColor Green
Write-Host "If Git aliases are missing, install Git: winget install Git.Git" -ForegroundColor Cyan
Write-Host "If Oh My Posh prompt is missing, install it: winget install JanDeDobbeleer.OhMyPosh" -ForegroundColor Cyan
