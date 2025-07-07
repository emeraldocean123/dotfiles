# Simple PowerShell Profile for Dotfiles
# Matches the cross-platform approach of the bash dotfiles

# Set encoding to UTF-8
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# Basic aliases matching bash_aliases
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name la -Value Get-ChildItem
Set-Alias -Name l -Value Get-ChildItem

# Git aliases
function gs { git status $args }
function ga { git add $args }
function gc { git commit $args }
function gp { git push $args }

# Navigation aliases
function .. { Set-Location .. }
function ... { Set-Location ..\.. }

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
