# === Joseph PowerShell Profile (PSReadLine pin + OMP + fastfetch) ===

# 1) Load bootstrap from repo (pins PSReadLine 2.4.1)
$repoBootstrap = Join-Path $HOME "Documents\dotfiles\powershell\profile.bootstrap.ps1"
if (Test-Path $repoBootstrap) { . $repoBootstrap }

# 2) Fastfetch (optional, once per session)
# Honor NO_FASTFETCH and set both a PowerShell and env guard
$noFF = [string]::IsNullOrEmpty($env:NO_FASTFETCH)
$shown = ($Global:FASTFETCH_SHOWN -eq $true) -or (-not [string]::IsNullOrEmpty($env:FASTFETCH_SHOWN))
if ($noFF -and -not $shown) {
    if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
        try {
            $ffsw = [System.Diagnostics.Stopwatch]::StartNew()
            fastfetch
            $ffsw.Stop()
        } catch {}
    }
    $Global:FASTFETCH_SHOWN = $true
    $env:FASTFETCH_SHOWN = '1'
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
    try {
        if (Test-Path $themePath) {
            oh-my-posh init pwsh --config $themePath | Invoke-Expression
        } else {
            oh-my-posh init pwsh | Invoke-Expression
        }
    } catch {
        Write-Verbose "Oh My Posh init failed: $($_.Exception.Message)" -Verbose:$false
    }
}

# 4) Git helpers
function gs { git status }
function gl { git --no-pager log --oneline -n 20 }
function gd { git --no-pager diff }

# 5) Quick Git path note and profile timing
$git = (Get-Command git -ErrorAction SilentlyContinue).Source
if ($git) { Write-Host "Git: $git" -ForegroundColor DarkGray }

# If VS Code PowerShell extension measures startup, keep output minimal; otherwise app note already printed above.

# END profile
