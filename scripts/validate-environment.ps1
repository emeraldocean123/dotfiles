#!/usr/bin/env pwsh
# Consolidated environment validation script
param(
    [switch]$PowerShell,
    [switch]$Theme,
    [switch]$SSH,
    [switch]$All,
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'

function Write-Section($title) { if (-not $Quiet) { Write-Host "`n=== $title ===" -ForegroundColor Cyan } }
function Write-Check($item, $status, $detail = "") {
    if (-not $Quiet) {
        $color = switch ($status) { "OK" { "Green" } "WARN" { "Yellow" } "FAIL" { "Red" } default { "Gray" } }
        $statusText = "[$status]"
        $line = "$item`: $statusText"
        if ($detail) { $line += " $detail" }
        Write-Host $line -ForegroundColor $color
    }
}

$overallSuccess = $true

# PowerShell Profile Validation
if ($PowerShell -or $All) {
    Write-Section "PowerShell Environment"
    
    # Check PSReadLine
    $psrl = Get-Module -ListAvailable PSReadLine | Sort-Object Version -Descending | Select-Object -First 1
    if ($psrl) {
        $expected = "2.4.1"
        $actual = $psrl.Version.ToString()
        if ($actual -eq $expected) {
            Write-Check "PSReadLine" "OK" "$actual"
        } else {
            Write-Check "PSReadLine" "WARN" "$actual (expected $expected)"
        }
    } else {
        Write-Check "PSReadLine" "FAIL" "not found"
        $overallSuccess = $false
    }
    
    # Check Oh My Posh
    $omp = Get-Command oh-my-posh -ErrorAction SilentlyContinue
    if ($omp) {
        Write-Check "Oh My Posh" "OK" $omp.Source
    } else {
        Write-Check "Oh My Posh" "FAIL" "not found on PATH"
        $overallSuccess = $false
    }
    
    # Check fastfetch
    $ff = Get-Command fastfetch -ErrorAction SilentlyContinue
    if ($ff) {
        Write-Check "Fastfetch" "OK" $ff.Source
    } else {
        Write-Check "Fastfetch" "WARN" "not found (optional)"
    }
    
    # Check environment guards
    if ($env:NO_FASTFETCH) {
        Write-Check "Fastfetch Guard" "OK" "NO_FASTFETCH is set"
    }
    if ($Global:FASTFETCH_SHOWN -or $env:FASTFETCH_SHOWN) {
        Write-Check "Fastfetch Guard" "OK" "FASTFETCH_SHOWN is set"
    }
}

# Theme Validation
if ($Theme -or $All) {
    Write-Section "Theme Configuration"
    
    $themePath = Join-Path $HOME 'Documents\dev\dotfiles\posh-themes\jandedobbeleer.omp.json'
    if (Test-Path $themePath) {
        try {
            $themeContent = Get-Content $themePath -Raw | ConvertFrom-Json
            Write-Check "Theme File" "OK" $themePath
            
            # Basic JSON structure validation
            if ($themeContent.version -and $themeContent.blocks) {
                Write-Check "Theme Structure" "OK" "version $($themeContent.version)"
            } else {
                Write-Check "Theme Structure" "WARN" "missing expected properties"
            }
        } catch {
            Write-Check "Theme File" "FAIL" "invalid JSON: $($_.Exception.Message)"
            $overallSuccess = $false
        }
    } else {
        Write-Check "Theme File" "FAIL" "not found at $themePath"
        $overallSuccess = $false
    }
}

# SSH Validation
if ($SSH -or $All) {
    Write-Section "SSH Connectivity"
    
    $sshCmd = Get-Command ssh -ErrorAction SilentlyContinue
    if ($sshCmd) {
        Write-Check "SSH Client" "OK" $sshCmd.Source
        
        # Test SSH key
        $sshDir = Join-Path $HOME '.ssh'
        $unifiedKey = Join-Path $sshDir 'id_ed25519_unified'
        if (Test-Path $unifiedKey) {
            Write-Check "Unified SSH Key" "OK" $unifiedKey
        } else {
            Write-Check "Unified SSH Key" "WARN" "not found at $unifiedKey"
        }
        
        # Quick connectivity test to GitHub
        try {
            $result = & ssh -T git@github.com 2>&1
            if ($result -like "*successfully authenticated*") {
                Write-Check "GitHub SSH" "OK" "authenticated"
            } else {
                Write-Check "GitHub SSH" "WARN" "authentication issue"
            }
        } catch {
            Write-Check "GitHub SSH" "FAIL" "connection failed"
        }
    } else {
        Write-Check "SSH Client" "FAIL" "not found"
        $overallSuccess = $false
    }
}

# Summary
if (-not $Quiet) {
    Write-Section "Summary"
    if ($overallSuccess) {
        Write-Host "✅ All critical checks passed" -ForegroundColor Green
    } else {
        Write-Host "❌ Some critical checks failed" -ForegroundColor Red
    }
}

exit $(if ($overallSuccess) { 0 } else { 1 })