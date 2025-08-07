# Joseph's PowerShell Profile
# Clean, optimized PowerShell configuration for dotfiles
# Version: 2025.11 - Prefer Fastfetch (with WinGet path fallback) for SSH-only banner

# Set encoding to UTF-8 for consistent display
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# Hard-code your dotfiles directory (your exact path)
$DotfilesDir = "C:\Users\josep\Documents\dotfiles"
$IsWindowsOs = $PSVersionTable.Platform -eq 'Win32NT' -or $env:OS -eq 'Windows_NT'

# Display expected directory structure
Write-Host "Expected directory structure for dotfiles (synced with Google Drive):" -ForegroundColor Cyan
Write-Host "  $DotfilesDir/" -ForegroundColor Cyan
Write-Host "  ├── bootstrap.ps1                    # Setup script" -ForegroundColor Cyan
Write-Host "  ├── powershell/" -ForegroundColor Cyan
Write-Host "  │   └── Microsoft.PowerShell_profile.ps1  # This PowerShell profile script" -ForegroundColor Cyan
Write-Host "  └── posh-themes/" -ForegroundColor Cyan
Write-Host "      └── jandedobbeleer.omp.json      # Oh My Posh theme file" -ForegroundColor Cyan

if (-not (Test-Path $DotfilesDir)) {
    Write-Host "Warning: Dotfiles directory '$DotfilesDir' does not exist. Some features (e.g., custom prompt) may not work." -ForegroundColor Yellow
}

# --- SSH-only Fastfetch banner on Windows (prefer Fastfetch, fallback Winfetch) ---
# We also look directly in WinGet's Links folder so it works *without restarting the shell*.
$IsSSH = [bool]($env:SSH_CONNECTION) -or [bool]($env:SSH_CLIENT)
if ($IsSSH) {
    # Candidate paths for fastfetch (prefer these in order)
    $fastfetchCandidates = @(
        (Get-Command fastfetch -ErrorAction SilentlyContinue)?.Source,
        "$env:LOCALAPPDATA\Microsoft\WinGet\Links\fastfetch.exe",
        "$env:ProgramFiles\fastfetch\fastfetch.exe",
        "$env:ProgramFiles\Fastfetch\fastfetch.exe"
    ) | Where-Object { $_ -and (Test-Path $_) }

    if ($fastfetchCandidates -and (Test-Path $fastfetchCandidates[0])) {
        try { & $fastfetchCandidates[0] } catch {}
    } else {
        # Fallback: Winfetch script if installed
        $wf = (Get-Command winfetch -ErrorAction SilentlyContinue)?.Source
        if ($wf) {
            try { & $wf } catch {}
        }
    }
}

# Directory listing functions
function ll { Get-ChildItem -Force $args }      # Detailed listing with hidden files (like ls -la)
function la { Get-ChildItem -Force $args }      # Same as ll
function l  { Get-ChildItem $args }             # Basic listing
function lsla { Get-ChildItem -Force $args }    # Explicit ls -la equivalent
function ls { Get-ChildItem $args }             # Basic ls (PS-native args)

# Robust PATH refresh for Git detection on Windows (+ WinGet Links so shims work in current session)
if ($IsWindowsOs) {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $gitPaths = @("C:\Program Files\Git\cmd","C:\Program Files (x86)\Git\cmd")
    foreach ($path in $gitPaths) { if (Test-Path $path) { $env:Path = "$env:Path;$path" } }

    # Ensure WinGet Links is in the *current* session PATH (helps right after installs)
    $wingetLinks = "$env:LOCALAPPDATA\Microsoft\WinGet\Links"
    if (Test-Path $wingetLinks -and ($env:Path -split ';' -notcontains $wingetLinks)) {
        $env:Path = "$env:Path;$wingetLinks"
    }
}

# Git aliases (as functions)
$gitFound = Get-Command git -ErrorAction SilentlyContinue
if ($gitFound) {
    Write-Host "Git detected at: $($gitFound.Source)" -ForegroundColor Green
    foreach ($a in 'gcm','gc','gp','gl') { if (Get-Alias -Name $a -ErrorAction SilentlyContinue) { Remove-Item -Path Alias:\$a -Force -ErrorAction SilentlyContinue } }
    function gs   { git status $args }
    function ga   { git add $args }
    function gcom { git commit $args }
    function gp   { git push $args }
    function gl   { git log --oneline -10 $args }
    function gd   { git diff $args }
} else {
    Write-Host "Warning: Git not found. Git aliases (gs, ga, gcom, gp, gl, gd) will not work. Install Git from: https://git-scm.com/download/win" -ForegroundColor Yellow
}

# Navigation
function ..   { Set-Location .. }
function ...  { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

# Utility helpers
function which($command) { Get-Command -Name $command -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source }
function reload-profile  { if (Test-Path $PROFILE) { . $PROFILE; Write-Host "Profile reloaded successfully" -ForegroundColor Green } else { Write-Host "Error: Profile '$PROFILE' not found" -ForegroundColor Red } }
function edit-profile    { if ($env:EDITOR -and (Get-Command $env:EDITOR -ErrorAction SilentlyContinue)) { & $env:EDITOR $PROFILE } else { Write-Host "Warning: $env:EDITOR not set. Opening Notepad." -ForegroundColor Yellow; notepad $PROFILE } }
function Get-Size($path = ".") { try { Get-ChildItem -Path $path -Recurse -File -ErrorAction Stop | Measure-Object -Property Length -Sum | Select-Object @{Name="Size(MB)";Expression={[math]::round($_.Sum/1MB,2)}} } catch { Write-Host "Error calculating size for '$path': $($_.Exception.Message)" -ForegroundColor Red } }

# Refresh module path for newly installed modules
Import-Module -Name PSReadLine,Terminal-Icons,z -Force -ErrorAction SilentlyContinue

# Enhanced modules with graceful fallbacks
$missingModules = @()
try {
    if (Get-Module -ListAvailable -Name PSReadLine) {
        Import-Module PSReadLine -ErrorAction Stop
        Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
        Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction SilentlyContinue
        Set-PSReadLineOption -EditMode Emacs -ErrorAction SilentlyContinue
    } else { $missingModules += "PSReadLine" }

    if (Get-Module -ListAvailable -Name Terminal-Icons) { Import-Module Terminal-Icons -ErrorAction Stop } else { $missingModules += "Terminal-Icons" }
    if (Get-Module -ListAvailable -Name z)               { Import-Module z -ErrorAction Stop               } else { $missingModules += "z" }
} catch {
    Write-Host "Error loading modules: $($_.Exception.Message)" -ForegroundColor Red
}
if ($missingModules) {
    Write-Host "Warning: Missing modules: $($missingModules -join ', '). Install with 'Install-Module <name> -Scope CurrentUser'." -ForegroundColor Yellow
}

# Oh My Posh prompt init
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    try {
        $customTheme = Join-Path $DotfilesDir "posh-themes\jandedobbeleer.omp.json"
        if (Test-Path $customTheme) {
            oh-my-posh init pwsh --config $customTheme | Invoke-Expression
        } elseif ($env:POSH_THEMES_PATH -and (Test-Path "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json")) {
            oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json" | Invoke-Expression
        } else {
            oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/clean-detailed.omp.json' | Invoke-Expression
            Write-Host "Warning: Custom Oh My Posh theme not found. Using a built-in theme." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error initializing Oh My Posh: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "Warning: Oh My Posh not installed. Install with 'winget install JanDeDobbeleer.OhMyPosh'." -ForegroundColor Yellow
}

# Success message
Write-Host "Joseph's PowerShell Environment Loaded (Version: 2025.11)" -ForegroundColor Green
Write-Host "Current Location: $(Get-Location)" -ForegroundColor Cyan
