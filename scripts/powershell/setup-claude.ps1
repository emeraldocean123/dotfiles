# === Claude Code Configuration Setup ===
param()
$ErrorActionPreference = 'Stop'

Write-Host "Setting up Claude Code configuration..." -ForegroundColor Cyan

$claudeDir = Join-Path $HOME ".claude"
if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
    Write-Host "Created $claudeDir directory" -ForegroundColor Green
}

$sharedClaudeDir = Join-Path $HOME "Documents/dev/shared/configs/claude"
$legacyClaudeDir = Join-Path $PSScriptRoot "claude"

if (Test-Path $sharedClaudeDir) {
    $sourceDir = $sharedClaudeDir
} elseif (Test-Path $legacyClaudeDir) {
    $sourceDir = $legacyClaudeDir
    Write-Warning "Using legacy claude/ directory in dotfiles; consider migrating to shared/configs."
} else {
    throw "Claude configuration files not found. Expected $sharedClaudeDir"
}

$files = @(
    @{ Name = "settings.json"; Target = "settings.json" },
    @{ Name = "settings.local.json"; Target = "settings.local.json" },
    @{ Name = "claude_desktop_config.json"; Target = "claude_desktop_config.json" },
    @{ Name = "claude_code_settings.json"; Target = "claude_code_settings.json" },
    @{ Name = "statusline.ps1"; Target = "statusline.ps1" }
)

foreach ($file in $files) {
    $source = Join-Path $sourceDir $file.Name
    $target = Join-Path $claudeDir $file.Target
    if (Test-Path $source) {
        Copy-Item $source $target -Force
        Write-Host "Copied $($file.Name)" -ForegroundColor Green
    }
}

Write-Host "Claude Code configuration setup complete!" -ForegroundColor Green
Write-Host "Settings installed to: $claudeDir" -ForegroundColor DarkGray
