# Joseph's Simple PowerShell Profile for Dotfiles
# Cross-platform PowerShell configuration that matches bash dotfiles

# Set encoding to UTF-8 for consistent display
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# Basic aliases matching bash_aliases
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name la -Value Get-ChildItem  
Set-Alias -Name l -Value Get-ChildItem

# Git aliases (matching bash_aliases)
function gs { git status $args }
function ga { git add $args }
function gc { git commit $args }
function gp { git push $args }

# Navigation aliases
function .. { Set-Location .. }
function ... { Set-Location ..\.. }

# Enhanced PowerShell modules (with error handling)
try {
    # Import PSReadLine for better command line editing
    if (Get-Module -ListAvailable -Name PSReadLine) {
        Import-Module PSReadLine -Force
        Set-PSReadLineOption -PredictionSource History
        Set-PSReadLineOption -PredictionViewStyle ListView
    }
    
    # Import Terminal-Icons for better file/folder icons
    if (Get-Module -ListAvailable -Name Terminal-Icons) {
        Import-Module Terminal-Icons
    }
    
    # Import z for directory jumping
    if (Get-Module -ListAvailable -Name z) {
        Import-Module z
    }
    
    # Import PSFzf for fuzzy finding (if available)
    if (Get-Module -ListAvailable -Name PSFzf) {
        Import-Module PSFzf
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'
    }
} catch {
    Write-Host "Some PowerShell modules failed to load: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Oh My Posh prompt (if available)
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    try {
        # Try to use the same theme as bash
        $poshTheme = "$env:USERPROFILE\dotfiles\posh-themes\jandedobbeleer.omp.json"
        if (Test-Path $poshTheme) {
            oh-my-posh init pwsh --config $poshTheme | Invoke-Expression
        } else {
            # Fallback to built-in theme
            oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json" | Invoke-Expression
        }
    } catch {
        Write-Host "Oh My Posh failed to initialize: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Welcome message
Write-Host "🚀 Joseph's PowerShell Environment Loaded" -ForegroundColor Green
Write-Host "📁 Current Location: $(Get-Location)" -ForegroundColor Cyan

# Helper functions
function which($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path
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

# Utility functions
function which($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
}

# Enhanced directory listing
function ll { Get-ChildItem -Force $args }
function la { Get-ChildItem -Force $args }

# Try to import enhanced modules if available (with error handling)
try {
    # PSReadLine for better command line editing
    if (Get-Module -ListAvailable PSReadLine) {
        Import-Module PSReadLine -ErrorAction SilentlyContinue
        Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
        Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction SilentlyContinue
    }

    # Terminal Icons for better file/folder icons
    if (Get-Module -ListAvailable Terminal-Icons) {
        Import-Module Terminal-Icons -ErrorAction SilentlyContinue
    }

    # z for directory jumping
    if (Get-Module -ListAvailable z) {
        Import-Module z -ErrorAction SilentlyContinue
    }

    # psfzf for fuzzy finding
    if (Get-Module -ListAvailable PSFzf) {
        Import-Module PSFzf -ErrorAction SilentlyContinue
    }
} catch {
    # Silently continue if modules fail to load
}

# Oh My Posh prompt (if available)
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    $poshTheme = "$env:USERPROFILE\dotfiles\posh-themes\jandedobbeleer.omp.json"
    if (Test-Path $poshTheme) {
        oh-my-posh init pwsh --config $poshTheme | Invoke-Expression
    } else {
        # Fallback to default theme
        oh-my-posh init pwsh | Invoke-Expression
    }
}

# Simple welcome message
Write-Host "✨ PowerShell dotfiles loaded successfully" -ForegroundColor Green
