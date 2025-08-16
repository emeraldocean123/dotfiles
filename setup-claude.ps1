# === Claude Code Configuration Setup ===
param()
$ErrorActionPreference = 'Stop'

Write-Host "Setting up Claude Code configuration..." -ForegroundColor Cyan

# Create .claude directory if it doesn't exist
$claudeDir = Join-Path $HOME ".claude"
if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
    Write-Host "Created $claudeDir directory" -ForegroundColor Green
}

# Copy Claude settings
$dotfilesClaudeDir = Join-Path $PSScriptRoot "claude"
$settingsSource = Join-Path $dotfilesClaudeDir "settings.json"
$settingsTarget = Join-Path $claudeDir "settings.json"

if (Test-Path $settingsSource) {
    Copy-Item $settingsSource $settingsTarget -Force
    Write-Host "Copied Claude Code settings.json" -ForegroundColor Green
} else {
    Write-Warning "Claude settings.json not found in dotfiles"
}

# Copy Claude desktop config  
$configSource = Join-Path $dotfilesClaudeDir "claude_desktop_config.json"
$configTarget = Join-Path $claudeDir "claude_desktop_config.json"

if (Test-Path $configSource) {
    Copy-Item $configSource $configTarget -Force
    Write-Host "Copied Claude desktop config" -ForegroundColor Green
} else {
    Write-Warning "Claude desktop config not found in dotfiles"
}

Write-Host "Claude Code configuration setup complete!" -ForegroundColor Green
Write-Host "Settings installed to: $claudeDir" -ForegroundColor DarkGray