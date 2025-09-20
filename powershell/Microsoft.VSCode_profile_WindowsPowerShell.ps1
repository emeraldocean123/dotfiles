# VS Code Windows PowerShell profile: reuse the main profile
$main = Join-Path $HOME 'Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1'
if (Test-Path $main) { . $main }

