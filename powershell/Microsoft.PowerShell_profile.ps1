# Joseph's PowerShell Profile
# Clean, optimized PowerShell configuration for dotfiles
# Version: 2025.9 - Use functions for Git aliases to fix subcommand issues

# Set encoding to UTF-8 for consistent display
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# Determine dotfiles directory (aligned with bootstrap script, synced with Google Drive)
$IsWindowsOs = $PSVersionTable.Platform -eq 'Win32NT' -or $env:OS -eq 'Windows_NT'
$DotfilesDir = if ($IsWindowsOs) { "$env:USERPROFILE\Documents\dotfiles" } else { "$env:HOME/Documents/dotfiles" }

# Display expected directory structure
Write-Host "Expected directory structure for dotfiles (synced with Google Drive):" -ForegroundColor Cyan
Write-Host "  $DotfilesDir/" -ForegroundColor Cyan
Write-Host "  ├── bootstrap.ps1                    # Setup script" -ForegroundColor Cyan
Write-Host "  ├── powershell/" -ForegroundColor Cyan
Write-Host "  │   └── Microsoft.PowerShell_profile.ps1  # This PowerShell profile script" -ForegroundColor Cyan
Write-Host "  └── posh-themes/" -ForegroundColor Cyan
Write-Host "      └── jandedobbeleer.omp.json      # Oh My Posh theme file" -ForegroundColor Cyan
Write-Host "Ensure '$DotfilesDir' is synced with Google Drive for cross-device consistency." -ForegroundColor Cyan

# Verify dotfiles directory
if (-not (Test-Path $DotfilesDir)) {
    Write-Host "Warning: Dotfiles directory '$DotfilesDir' does not exist. Some features (e.g., custom prompt) may not work." -ForegroundColor Yellow
    Write-Host "Create the directory structure shown above or run the bootstrap script with -CustomDotfilesDir." -ForegroundColor Yellow
}

# Directory listing functions (PowerShell-compatible)
function ll { Get-ChildItem -Force $args }      # Detailed listing with hidden files (like ls -la)
function la { Get-ChildItem -Force $args }      # Same as ll
function l { Get-ChildItem $args }              # Basic listing
function lsla { Get-ChildItem -Force $args }    # Explicit ls -la equivalent
function ls { Get-ChildItem $args }             # Basic ls (supports PowerShell args only)

# Robust PATH refresh for Git detection
if ($IsWindowsOs) {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    # Add common Git paths if not found
    $gitPaths = @(
        "C:\Program Files\Git\cmd",
        "C:\Program Files (x86)\Git\cmd"
    )
    foreach ($path in $gitPaths) {
        if (Test-Path $path) {
            $env:Path = "$env:Path;$path"
        }
    }
}

# Git aliases (using functions to handle subcommands correctly)
$gitFound = Get-Command git -ErrorAction SilentlyContinue
if ($gitFound) {
    Write-Host "Git detected at: $($gitFound.Source)" -ForegroundColor Green
    # Remove conflicting built-in aliases
    if (Get-Alias -Name gcm -ErrorAction SilentlyContinue) {
        Remove-Item -Path Alias:\gcm -Force -ErrorAction SilentlyContinue
    }
    if (Get-Alias -Name gc -ErrorAction SilentlyContinue) {
        Remove-Item -Path Alias:\gc -Force -ErrorAction SilentlyContinue
    }
    if (Get-Alias -Name gp -ErrorAction SilentlyContinue) {
        Remove-Item -Path Alias:\gp -Force -ErrorAction SilentlyContinue
    }
    if (Get-Alias -Name gl -ErrorAction SilentlyContinue) {
        Remove-Item -Path Alias:\gl -Force -ErrorAction SilentlyContinue
    }
    # Define Git aliases as functions
    function gs { git status $args }
    function ga { git add $args }
    function gcom { git commit $args }
    function gp { git push $args }
    function gl { git log --oneline -10 $args }
    function gd { git diff $args }
} else {
    Write-Host "Warning: Git not found. Git aliases (gs, ga, gcom, gp, gl, gd) will not work. Install Git from: https://git-scm.com/download/win" -ForegroundColor Yellow
    Write-Host "Run 'winget install Git.Git' or ensure Git is in PATH." -ForegroundColor Yellow
}

# Navigation aliases
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

# Utility functions
function which($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
}

function reload-profile {
    if (Test-Path $PROFILE) {
        . $PROFILE
        Write-Host "Profile reloaded successfully" -ForegroundColor Green
    } else {
        Write-Host "Error: Profile file not found at $PROFILE" -ForegroundColor Red
    }
}

function edit-profile {
    if ($env:EDITOR -and (Get-Command $env:EDITOR -ErrorAction SilentlyContinue)) {
        & $env:EDITOR $PROFILE
    } else {
        Write-Host "Warning: $env:EDITOR not set or invalid. Falling back to Notepad." -ForegroundColor Yellow
        notepad $PROFILE
    }
}

function Get-Size($path = ".") {
    try {
        Get-ChildItem -Path $path -Recurse -File -ErrorAction Stop | Measure-Object -Property Length -Sum | Select-Object @{Name="Size(MB)";Expression={[math]::round($_.Sum/1MB,2)}}
    } catch {
        Write-Host "Error calculating size for '$path': $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Refresh module path to ensure newly installed modules are available
Import-Module -Name PSReadLine,Terminal-Icons,z -Force -ErrorAction SilentlyContinue

# Enhanced PowerShell modules (with robust error handling)
$missingModules = @()
try {
    # PSReadLine for better command line editing
    if (Get-Module -ListAvailable -Name PSReadLine) {
        Import-Module PSReadLine -ErrorAction Stop
        Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
        Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction SilentlyContinue
        Set-PSReadLineOption -EditMode Emacs -ErrorAction SilentlyContinue
    } else {
        $missingModules += "PSReadLine"
    }
    
    # Terminal-Icons for better file/folder icons  
    if (Get-Module -ListAvailable -Name Terminal-Icons) {
        Import-Module Terminal-Icons -ErrorAction Stop
    } else {
        $missingModules += "Terminal-Icons"
    }
    
    # Z for directory jumping
    if (Get-Module -ListAvailable -Name z) {
        Import-Module z -ErrorAction Stop
    } else {
        $missingModules += "z"
    }
} catch {
    Write-Host "Error loading modules: $($_.Exception.Message)" -ForegroundColor Red
}

if ($missingModules) {
    Write-Host "Warning: The following modules are not installed: $($missingModules -join ', '). Install them with 'Install-Module <name> -Scope CurrentUser'." -ForegroundColor Yellow
}

# Oh My Posh prompt initialization
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    try {
        # Try custom theme first, aligned with bootstrap script's $DotfilesDir
        $customTheme = Join-Path $DotfilesDir "posh-themes\jandedobbeleer.omp.json"
        if (Test-Path $customTheme) {
            oh-my-posh init pwsh --config $customTheme | Invoke-Expression
        } elseif ($env:POSH_THEMES_PATH -and (Test-Path "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json")) {
            oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json" | Invoke-Expression
        } else {
            # Fallback to a built-in theme
            oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/clean-detailed.omp.json' | Invoke-Expression
            Write-Host "Warning: Custom theme not found at $customTheme. Using default Oh My Posh theme." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error initializing Oh My Posh: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "Warning: Oh My Posh not installed. Prompt customization unavailable. Install with 'winget install JanDeDobbeleer.OhMyPosh' or follow: https://ohmyposh.dev/docs/installation/windows" -ForegroundColor Yellow
}

# Success message
Write-Host "Joseph's PowerShell Environment Loaded (Version: 2025.9)" -ForegroundColor Green
Write-Host "Current Location: $(Get-Location)" -ForegroundColor Cyan
Write-Host "PowerShell dotfiles loaded successfully" -ForegroundColor Green
if ($missingModules -or -not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    Write-Host "Note: Some features may be missing due to uninstalled modules or tools. Run the bootstrap script without -SkipModuleInstall or install manually." -ForegroundColor Cyan
}