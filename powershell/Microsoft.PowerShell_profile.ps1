# === Joseph PowerShell Profile (PSReadLine pin + OMP + fastfetch) ===

# 1) Load bootstrap from repo (pins PSReadLine 2.4.1)
$repoBootstrap = Join-Path $HOME "Documents\dev\dotfiles\powershell\profile.bootstrap.ps1"
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
# Note: Oh My Posh can cause infinite loops in PowerShell 5.1, so we skip it for compatibility
$themePath = Join-Path $HOME 'Documents\dev\dotfiles\posh-themes\jandedobbeleer.omp.json'
if ($omp -and $PSVersionTable.PSVersion.Major -ge 6) {
    try {
        if (Test-Path $themePath) {
            oh-my-posh init pwsh --config $themePath | Invoke-Expression
        } else {
            oh-my-posh init pwsh | Invoke-Expression
        }
    } catch {
        Write-Verbose "Oh My Posh init failed: $($_.Exception.Message)" -Verbose:$false
    }
} elseif ($omp -and $PSVersionTable.PSVersion.Major -lt 6) {
    Write-Host "Oh My Posh disabled for PowerShell 5.1 compatibility. Use PowerShell 7+ for full theme support." -ForegroundColor Yellow
}

# 4) Git helpers (matches bash aliases)
function gs { git status }
function ga { git add @args }
function gcom { git commit @args }
function gp { git push @args }
function gl { git --no-pager log --oneline -n 10 }  # Changed to -n 10 to match bash
function gd { git --no-pager diff @args }

# Directory navigation (matches bash aliases)
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .... { Set-Location ../../.. }

# Directory listing (matches bash aliases)
function ll { Get-ChildItem -Force }  # Shows all files including hidden
function la { Get-ChildItem -Force }  # Same as ll
function l { Get-ChildItem }           # Normal listing without hidden files

# 5) Quick Git path note and profile timing
$git = (Get-Command git -ErrorAction SilentlyContinue).Source
if ($git) { Write-Host "Git: $git" -ForegroundColor DarkGray }

# If VS Code PowerShell extension measures startup, keep output minimal; otherwise app note already printed above.

# END profile
