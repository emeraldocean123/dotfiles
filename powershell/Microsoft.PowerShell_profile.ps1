# Joseph's PowerShell Profile
# Clean, optimized PowerShell configuration for dotfiles
# Version: 2025.1 - Freeze issues resolved

# Set encoding to UTF-8 for consistent display
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# Directory listing functions (PowerShell-compatible)
# NOTE: Unix-style flags like 'ls -la' don't work in PowerShell due to argument parsing
function ll { Get-ChildItem -Force $args }      # Detailed listing with hidden files (like ls -la)
function la { Get-ChildItem -Force $args }      # Same as ll
function l { Get-ChildItem $args }              # Basic listing
function lsla { Get-ChildItem -Force $args }    # Explicit ls -la equivalent
function ls { Get-ChildItem $args }             # Basic ls (supports PowerShell args only)

# Git aliases (matching bash_aliases)
function gs { git status $args }
function ga { git add $args }
function gc { git commit $args }
function gp { git push $args }
function gl { git log --oneline -10 }
function gd { git diff $args }

# Navigation aliases
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

# Utility functions
function which($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
}

function reload-profile {
    & $profile
}

function edit-profile {
    if ($env:EDITOR) {
        & $env:EDITOR $profile
    } else {
        notepad $profile
    }
}

function Get-Size($path = ".") {
    Get-ChildItem -Path $path -Recurse -File | Measure-Object -Property Length -Sum | Select-Object @{Name="Size(MB)";Expression={[math]::round($_.Sum/1MB,2)}}
}

# Enhanced PowerShell modules (with robust error handling)
try {
    # PSReadLine for better command line editing
    if (Get-Module -ListAvailable -Name PSReadLine) {
        Import-Module PSReadLine -ErrorAction SilentlyContinue
        if (Get-Module PSReadLine) {
            Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
            Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction SilentlyContinue
            Set-PSReadLineOption -EditMode Emacs -ErrorAction SilentlyContinue
        }
    }
    
    # Terminal-Icons for better file/folder icons  
    if (Get-Module -ListAvailable -Name Terminal-Icons) {
        Import-Module Terminal-Icons -ErrorAction SilentlyContinue
    }
    
    # Z for directory jumping (if available)
    if (Get-Module -ListAvailable -Name z) {
        Import-Module z -ErrorAction SilentlyContinue
    }
    
    # PSFzf - DISABLED due to fzf binary PATH issues
    # Uncomment when fzf is properly installed and in PATH
    # if (Get-Module -ListAvailable -Name PSFzf) {
    #     Import-Module PSFzf -ErrorAction SilentlyContinue
    #     if (Get-Module PSFzf) {
    #         Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r' -ErrorAction SilentlyContinue
    #     }
    # }
    
} catch {
    Write-Host "Warning: Some PowerShell modules failed to load: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Oh My Posh prompt initialization
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    try {
        # Try custom theme first, fallback to default
        $customTheme = "$env:USERPROFILE\dotfiles\posh-themes\jandedobbeleer.omp.json"
        if (Test-Path $customTheme) {
            oh-my-posh init pwsh --config $customTheme | Invoke-Expression
        } elseif ($env:POSH_THEMES_PATH -and (Test-Path "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json")) {
            oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json" | Invoke-Expression
        } else {
            # Fallback to a simple built-in theme
            oh-my-posh init pwsh | Invoke-Expression
        }
    } catch {
        Write-Host "Warning: Oh My Posh failed to initialize: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Success message
Write-Host "🚀 Joseph's PowerShell Environment Loaded" -ForegroundColor Green
Write-Host "📁 Current Location: $(Get-Location)" -ForegroundColor Cyan
Write-Host "✨ PowerShell dotfiles loaded successfully" -ForegroundColor Green
