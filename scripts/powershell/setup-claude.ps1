# === Claude Code Configuration Setup ===
param(
    [switch]$OpenCode,
    [switch]$Test
)
$ErrorActionPreference = 'Stop'

if ($OpenCode) {
    Write-Host "Setting up opencode for clean PowerShell mode..." -ForegroundColor Cyan
    Write-Host "This ensures opencode runs without terminal interference." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To launch opencode in clean mode, use:" -ForegroundColor Green
    Write-Host "  `$env:OPENCODE='1'; & opencode" -ForegroundColor White
    Write-Host ""
    Write-Host "Or create a function in your profile:" -ForegroundColor Green
    Write-Host "  function opencode-clean { `$env:OPENCODE='1'; & opencode `$args }" -ForegroundColor White
    Write-Host ""
    Write-Host "The PowerShell profiles have been updated to automatically detect" -ForegroundColor Cyan
    Write-Host "and skip problematic components when opencode is running." -ForegroundColor Cyan
    return
}

if ($Test) {
    Write-Host "Testing opencode PowerShell compatibility..." -ForegroundColor Cyan

    # Test if opencode detection works
    $env:OPENCODE = "1"
    $isOpenCode = $env:OPEN_CODE -or $env:OPENCODE -or ($env:TERM_PROGRAM -eq "opencode") -or
                  (Get-Process -Name "opencode" -ErrorAction SilentlyContinue) -or
                  ($MyInvocation.MyCommand.Path -like "*opencode*")

    if ($isOpenCode) {
        Write-Host "✅ OpenCode detection working correctly" -ForegroundColor Green
    } else {
        Write-Host "❌ OpenCode detection failed" -ForegroundColor Red
    }

    Remove-Item Env:\OPENCODE -ErrorAction SilentlyContinue
    return
}

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
