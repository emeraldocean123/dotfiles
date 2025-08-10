param(
    [switch]$Force,
    [switch]$AutoPush,
    [string]$CustomDotfilesDir
)

$ErrorActionPreference = 'Stop'

function Write-Info($msg){ Write-Host $msg -ForegroundColor Cyan }
function Write-Ok($msg){ Write-Host $msg -ForegroundColor Green }
function Write-Warn($msg){ Write-Warning $msg }
function Write-Err($msg){ Write-Host $msg -ForegroundColor Red }

# -------------------------------
# Pinned versions / constants
# -------------------------------
$PinnedPSReadLineVersion = '2.4.1'   # change here if/when you bump
$RequiredModules = @('Terminal-Icons','z')  # PSReadLine handled specially

Write-Info "Starting PowerShell dotfiles setup..."

# -------------------------------
# Detect platform / paths
# -------------------------------
$OnWindows = $PSVersionTable.Platform -eq 'Win32NT' -or $env:OS -eq 'Windows_NT'
$OnLinux   = $PSVersionTable.Platform -eq 'Unix' -and $PSVersionTable.OS -like '*Linux*'
$OnMac     = $PSVersionTable.Platform -eq 'Unix' -and $PSVersionTable.OS -like '*Darwin*'

Write-Info ("Platform: " + ($(if($OnWindows){'Windows'}elseif($OnLinux){'Linux'}elseif($OnMac){'macOS'}else{'Unknown'})))
Write-Ok   ("PowerShell Version: " + $PSVersionTable.PSVersion)

if ($CustomDotfilesDir) {
    $DotfilesDir = $CustomDotfilesDir
} elseif ($OnWindows) {
    $ProfileDir  = if ($PSVersionTable.PSVersion.Major -le 5) { "$env:USERPROFILE\Documents\WindowsPowerShell" } else { "$env:USERPROFILE\Documents\PowerShell" }
    $DotfilesDir = "$env:USERPROFILE\Documents\dotfiles"
} else {
    $ProfileDir  = "$env:HOME/.config/powershell"
    $DotfilesDir = "$env:HOME/Documents/dotfiles"
}
$ProfilePath = Join-Path $ProfileDir 'Microsoft.PowerShell_profile.ps1'
$BackupDir   = Join-Path $env:USERPROFILE ("dotfiles-backup-{0}" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))

# Vendored module path inside repo
$VendoredPSRL = Join-Path $DotfilesDir ("modules\PSReadLine\{0}" -f $PinnedPSReadLineVersion)

Write-Info "Expected directory structure (synced with cloud):"
Write-Host "  $DotfilesDir/"
Write-Host "  ├── bootstrap.ps1"
Write-Host "  ├── powershell/Microsoft.PowerShell_profile.ps1"
Write-Host "  └── posh-themes/jandedobbeleer.omp.json"
Write-Info "Profile will be copied to: $ProfilePath"

# Verify required files
$SourceProfile = Join-Path $DotfilesDir 'powershell\Microsoft.PowerShell_profile.ps1'
$ThemePath     = Join-Path $DotfilesDir 'posh-themes\jandedobbeleer.omp.json'
$BootstrapPath = Join-Path $DotfilesDir 'bootstrap.ps1'
$missing = @()
if (!(Test-Path $DotfilesDir))   { $missing += $DotfilesDir }
if (!(Test-Path $SourceProfile)) { $missing += $SourceProfile }
if (!(Test-Path $ThemePath))     { $missing += $ThemePath }
if (!(Test-Path $BootstrapPath)) { $missing += $BootstrapPath }

if ($missing.Count -gt 0) {
    Write-Err "Missing required path(s):"
    $missing | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
} else {
    Write-Ok "Directory structure verified successfully"
}

# Ensure profile dir
if (!(Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
    Write-Ok "Created profile directory: $ProfileDir"
}

# Refresh PATH
$env:Path = [Environment]::GetEnvironmentVariable('Path','User') + ';' + [Environment]::GetEnvironmentVariable('Path','Machine')

# -------------------------------
# Install core tools (Windows)
# -------------------------------
function Invoke-WingetInstall($id) {
    if ($OnWindows -and (Get-Command winget -ErrorAction SilentlyContinue)) {
        try {
            winget install --id=$id --accept-source-agreements --accept-package-agreements --silent | Out-Null
            Write-Ok "Installed/verified: $id"
            $env:Path = [Environment]::GetEnvironmentVariable('Path','User') + ';' + [Environment]::GetEnvironmentVariable('Path','Machine')
        } catch {
            Write-Warn "winget install failed for $id -> $($_.Exception.Message)"
        }
    }
}

if ($OnWindows) {
    if (-not (Get-Command git -ErrorAction SilentlyContinue))       { Invoke-WingetInstall 'Git.Git' }
    if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)){ Invoke-WingetInstall 'JanDeDobbeleer.OhMyPosh' }
    if (-not (Get-Command fastfetch -ErrorAction SilentlyContinue)) { Invoke-WingetInstall 'Fastfetch-cli.Fastfetch' }
}

# -------------------------------
# Install non-pinned modules
# -------------------------------
foreach ($m in $RequiredModules) {
    if (-not (Get-Module -ListAvailable -Name $m)) {
        try {
            Install-Module -Name $m -Scope CurrentUser -Force -ErrorAction Stop
            Write-Ok "Installed module: $m"
        } catch {
            Write-Warn ("Could not install module {0}: {1}" -f $m, $_.Exception.Message)
        }
    } else {
        Write-Ok "Module $m already installed"
    }
}

# -------------------------------
# PSReadLine: pinned & vendored
# -------------------------------
$UserModulesRoot = Join-Path $env:USERPROFILE 'Documents\PowerShell\Modules'
$UserPSRLTarget  = Join-Path $UserModulesRoot ("PSReadLine\{0}" -f $PinnedPSReadLineVersion)

function Import-PinnedPSReadLine {
    param([string]$TargetPath)
    try {
        Import-Module $TargetPath -Force -ErrorAction Stop
        Write-Ok "Imported PSReadLine $PinnedPSReadLineVersion from $TargetPath"
        return $true
    } catch {
        Write-Warn ("Failed to import vendored PSReadLine {0}: {1}" -f $PinnedPSReadLineVersion, $_.Exception.Message)
        return $false
    }
}

# Try vendored -> copy to user modules if present
if (Test-Path $VendoredPSRL) {
    if (!(Test-Path $UserPSRLTarget)) {
        New-Item -ItemType Directory -Path $UserPSRLTarget -Force | Out-Null
        Copy-Item -Path (Join-Path $VendoredPSRL '*') -Destination $UserPSRLTarget -Recurse -Force
        Write-Ok "Copied vendored PSReadLine $PinnedPSReadLineVersion into $UserPSRLTarget"
    }
    $null = Import-PinnedPSReadLine -TargetPath $UserPSRLTarget
} else {
    # No vendored copy; fall back to any installed version, but warn if not the pinned one
    $psrl = Get-Module -ListAvailable PSReadLine | Sort-Object Version -Descending | Select-Object -First 1
    if ($psrl) {
        if ($psrl.Version.ToString() -ne $PinnedPSReadLineVersion) {
            Write-Warn ("PSReadLine {0} found, not pinned {1}. Consider vendoring under {2}" -f $psrl.Version, $PinnedPSReadLineVersion, $VendoredPSRL)
        }
        try {
            Import-Module PSReadLine -Force
            Write-Ok "Imported PSReadLine $($psrl.Version)"
        } catch {
            Write-Warn ("Import-Module PSReadLine failed: {0}" -f $_.Exception.Message)
        }
    } else {
        Write-Warn "PSReadLine not found and no vendored copy at $VendoredPSRL. You can vendor it with the helper script (see below)."
    }
}

# -------------------------------
# Copy profile (with backup)
# -------------------------------
try {
    if (Test-Path $SourceProfile) {
        if ((Test-Path $ProfilePath) -and -not $Force) {
            Write-Warn "Profile exists at $ProfilePath. Use -Force to overwrite."
        } else {
            if (Test-Path $ProfilePath) {
                New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
                Copy-Item -Path $ProfilePath -Destination $BackupDir -Force
                Write-Ok "Backed up existing profile to $BackupDir"
            }
            Copy-Item -Path $SourceProfile -Destination $ProfilePath -Force
            Write-Ok "Copied profile to $ProfilePath"
        }
    } else {
        Write-Err "Source profile not found at $SourceProfile"
        exit 1
    }
} catch {
    Write-Err ("Error copying profile: {0}" -f $_.Exception.Message)
    exit 1
}

# -------------------------------
# Source profile
# -------------------------------
if (Test-Path $ProfilePath) {
    . $ProfilePath
    Write-Ok "Profile sourced successfully"
} else {
    Write-Err "Profile not found at $ProfilePath after copy"
    exit 1
}

# -------------------------------
# GitHub SSH (Windows)
# -------------------------------
if ($OnWindows) {
    $SshDir        = Join-Path $env:USERPROFILE '.ssh'
    $SshConfigPath = Join-Path $SshDir 'config'
    $KeyPath       = Join-Path $SshDir 'id_ed25519_github'
    $OpenSshExe    = 'C:\Windows\System32\OpenSSH\ssh.exe'

    if (!(Test-Path $SshDir)) { New-Item -ItemType Directory -Path $SshDir -Force | Out-Null; Write-Ok "Created: $SshDir" }

    try {
        $svc = Get-Service ssh-agent -ErrorAction Stop
        if ($svc.StartType -ne 'Automatic') { Set-Service ssh-agent -StartupType Automatic }
        if ($svc.Status -ne 'Running') { Start-Service ssh-agent }
        Write-Ok "ssh-agent is running (StartupType=Automatic)"
    } catch {
        Write-Warn ("Could not configure ssh-agent service: {0}" -f $_.Exception.Message)
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
            $newCfg = [Regex]::Replace($cfg,"(?ms)^Host\s+github\.com\b.*?(?=^Host\s|\Z)",$configBlock)
            $newCfg | Out-File -FilePath $SshConfigPath -Encoding ascii -Force
            Write-Ok "Updated github.com block in ~/.ssh/config"
        } else {
            Add-Content -Path $SshConfigPath -Value "`r`n$configBlock"
            Write-Ok "Appended github.com block to ~/.ssh/config"
        }
    } else {
        $configBlock | Out-File -FilePath $SshConfigPath -Encoding ascii -Force
        Write-Ok "Created ~/.ssh/config"
    }

    try {
        git config --global core.sshCommand $OpenSshExe | Out-Null
        Write-Ok "Set git core.sshCommand -> $OpenSshExe"
    } catch {
        Write-Warn ("Could not set git core.sshCommand: {0}" -f $_.Exception.Message)
    }

    if (Test-Path $KeyPath) {
        try {
            $list = ssh-add -l 2>$null
            $pub = Get-Content "$KeyPath.pub" -ErrorAction SilentlyContinue
            if (-not $pub -or -not ($list -match [Regex]::Escape($pub))) {
                ssh-add $KeyPath | Out-Null
                Write-Ok "Added key to agent: $KeyPath"
            } else {
                Write-Ok "Key already loaded in agent: $KeyPath"
            }
        } catch {
            Write-Warn ("Could not add key to agent: {0}" -f $_.Exception.Message)
        }
    } else {
        Write-Warn "Note: $KeyPath not found. Generate with: ssh-keygen -t ed25519 -C '<email>' -f '$KeyPath'"
    }
}

# -------------------------------
# Auto Git push (optional)
# -------------------------------
if ($AutoPush) {
    Write-Info "`n--- Auto Git Sync Starting ---"
    try {
        Push-Location $DotfilesDir
        git add -A
        $status = git status --porcelain
        if ($status) {
            $msg = "Auto update {0}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
            git commit -m $msg
            git push
        } else {
            Write-Info "Nothing to commit"
        }
    } catch {
        Write-Warn ("Auto-push failed: {0}" -f $_.Exception.Message)
    } finally {
        Pop-Location
        Write-Info "--- Auto Git Sync Complete ---`n"
    }
}

Write-Ok "Bootstrap complete."

# Next steps hint
Write-Info "\nNext steps:"
Write-Info "  - Verify profile: powershell/Verify-Profile.ps1"
if ($OnWindows) {
    Write-Info "  - Validate theme (Windows): scripts/check-theme.ps1"
} elseif ($OnLinux) {
    Write-Info "  - Validate theme (Linux): scripts/check-theme.sh"
}
