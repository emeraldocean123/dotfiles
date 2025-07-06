$target = "$HOME\\Documents\\PowerShell\\Microsoft.PowerShell_profile.ps1"
$source = "$PSScriptRoot\\Microsoft.PowerShell_profile.ps1"
New-Item -ItemType Directory -Path (Split-Path $target) -Force
Copy-Item -Path $source -Destination $target -Force
Write-Host "✅ PowerShell profile installed."
