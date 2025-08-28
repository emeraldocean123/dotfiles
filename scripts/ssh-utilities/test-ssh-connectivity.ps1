#!/usr/bin/env pwsh
# Consolidated SSH connectivity testing utility
param(
    [string]$Target = "",
    [switch]$All,
    [switch]$Quiet,
    [int]$TimeoutSec = 5
)

$ErrorActionPreference = 'SilentlyContinue'

function Write-Info($m) { if (-not $Quiet) { Write-Host $m -ForegroundColor Cyan } }
function Write-Success($m) { if (-not $Quiet) { Write-Host $m -ForegroundColor Green } }
function Write-Fail($m) { if (-not $Quiet) { Write-Host $m -ForegroundColor Red } }
function Write-Warn($m) { if (-not $Quiet) { Write-Host $m -ForegroundColor Yellow } }

# Predefined infrastructure hosts from CLAUDE.md
$InfrastructureHosts = @(
    @{Name="GitHub"; Host="git@github.com"; Special="github"},
    @{Name="Synology NAS"; Host="joseph@nas"; IP="192.168.1.10"},
    @{Name="HP Laptop"; Host="joseph@hp"; IP="192.168.1.104"},
    @{Name="MSI Laptop"; Host="joseph@msi"; IP="192.168.1.106"},
    @{Name="Proxmox Host"; Host="root@proxmox"; IP="192.168.1.40"},
    @{Name="OPNsense Router"; Host="joseph@opnsense"; IP="192.168.1.1"},
    @{Name="WireGuard LXC"; Host="root@wireguard"; IP="192.168.1.50"},
    @{Name="Tailscale LXC"; Host="root@tailscale"; IP="192.168.1.51"},
    @{Name="Omada LXC"; Host="root@omada"; IP="192.168.1.52"},
    @{Name="NetBox LXC"; Host="root@netbox"; IP="192.168.1.53"},
    @{Name="iVentoy LXC"; Host="root@iventoy"; IP="192.168.1.54"},
    @{Name="Docker LXC"; Host="root@docker"; IP="192.168.1.55"},
    @{Name="Syncthing LXC"; Host="root@syncthing"; IP="192.168.1.56"}
)

function Test-SingleHost {
    param([string]$HostTarget, [string]$DisplayName = $HostTarget, [string]$Special = "")
    
    if ($Special -eq "github") {
        # Special GitHub test
        $result = & ssh -T $HostTarget 2>&1
        if ($result -like "*successfully authenticated*") {
            Write-Success "$DisplayName`: Connected"
            return $true
        } else {
            Write-Fail "$DisplayName`: Failed"
            return $false
        }
    } else {
        # Standard host test
        $result = & ssh -o ConnectTimeout=$TimeoutSec -o PasswordAuthentication=no $HostTarget "hostname" 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "$DisplayName`: Connected ($result)"
            return $true
        } else {
            Write-Fail "$DisplayName`: Failed"
            return $false
        }
    }
}

# Main execution
if (-not (Get-Command ssh -ErrorAction SilentlyContinue)) {
    Write-Fail "SSH not found. Install OpenSSH Client."
    exit 1
}

if ($All) {
    Write-Info "Testing SSH connectivity to all infrastructure hosts..."
    Write-Info ""
    
    $successful = 0
    $failed = 0
    
    foreach ($system in $InfrastructureHosts) {
        $result = Test-SingleHost -HostTarget $system.Host -DisplayName $system.Name -Special $system.Special
        if ($result) { $successful++ } else { $failed++ }
    }
    
    Write-Info ""
    Write-Info "===== SUMMARY ====="
    Write-Success "Successful: $successful"
    Write-Fail "Failed: $failed"
    
    if ($failed -eq 0) {
        Write-Success "All systems accessible!"
        exit 0
    } else {
        Write-Warn "Some systems need attention"
        exit 1
    }
} elseif ($Target) {
    Write-Info "Testing SSH connectivity to $Target..."
    $result = Test-SingleHost -HostTarget $Target -DisplayName $Target
    exit $(if ($result) { 0 } else { 1 })
} else {
    Write-Host "SSH Connectivity Tester" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  Test single host:  .\test-ssh-connectivity.ps1 -Target 'user@hostname'"
    Write-Host "  Test all hosts:    .\test-ssh-connectivity.ps1 -All"
    Write-Host "  Quiet mode:        .\test-ssh-connectivity.ps1 -All -Quiet"
    Write-Host ""
    Write-Host "Available infrastructure hosts:"
    foreach ($system in $InfrastructureHosts) {
        Write-Host "  - $($system.Name) ($($system.Host))" -ForegroundColor DarkGray
    }
    exit 0
}
