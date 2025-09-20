#!/usr/bin/env pwsh
# VS Code PowerShell profile: reuse the main profile
$main = Join-Path $HOME 'Documents/PowerShell/Microsoft.PowerShell_profile.ps1'
if (Test-Path $main) { . $main }

