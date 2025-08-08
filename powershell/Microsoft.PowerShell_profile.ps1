# === Joseph PowerShell Profile (PSReadLine pin + OMP + fastfetch) ===

# 1) Load bootstrap from repo (pins PSReadLine 2.4.1)
$repoBootstrap = Join-Path $HOME "Documents\dotfiles\powershell\profile.bootstrap.ps1"
if (Test-Path $repoBootstrap) { . $repoBootstrap }

# 2) Fastfetch (optional)
if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    try { fastfetch } catch {}
}

# 3) Oh My Posh prompt
# Find oh-my-posh. If missing on PATH, try the common winget path quietly.
$omp = (Get-Command oh-my-posh -ErrorAction SilentlyContinue).Source
if (-not $omp) {
    $wingetLinks = Join-Path $env:LOCALAPPDATA 'Programs\oh-my-posh\bin'
    if (Test-Path $wingetLinks -and (($env:Path -split ';') -notcontains $wingetLinks)) {
        $env:Path = $env:Path + ';' + $wingetLinks
        $omp = (Get-Command oh-my-posh -ErrorAction SilentlyContinue).Source
    }
}

# Theme from dotfiles if available; otherwise default oh-my-posh init
$themePath = Join-Path $HOME 'Documents\dotfiles\posh-themes\jandedobbeleer.omp.json'
if ($omp) {
    if (Test-Path $themePath) {
        oh-my-posh init pwsh --config $themePath | Invoke-Expression
    } else {
        oh-my-posh init pwsh | Invoke-Expression
    }
}

# 4) Git helpers
function gs { git status }
function gl { git --no-pager log --oneline -n 20 }
function gd { git --no-pager diff }

# 5) Quick Git path note
$git = (Get-Command git -ErrorAction SilentlyContinue).Source
if ($git) { Write-Host "Git: $git" -ForegroundColor DarkGray }

# END profile
