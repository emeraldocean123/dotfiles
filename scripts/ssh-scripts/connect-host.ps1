#!/usr/bin/env pwsh
# Unified SSH connection utility for infrastructure hosts
param(
    [Parameter(Position=0, Mandatory=$true)]
    [string]$HostAlias,
    
    [string]$Command = "",
    [switch]$Interactive,
    [switch]$Info
)

$ErrorActionPreference = 'Stop'

# Infrastructure host mappings from CLAUDE.md
$HostMap = @{
    "nas" = @{Target="joseph@nas"; IP="192.168.1.10"; Name="Synology NAS"}
    "hp" = @{Target="joseph@hp"; IP="192.168.1.104"; Name="HP Laptop (NixOS)"}
    "msi" = @{Target="joseph@msi"; IP="192.168.1.106"; Name="MSI Laptop (NixOS)"}
    "proxmox" = @{Target="root@proxmox"; IP="192.168.1.40"; Name="Proxmox VE"}
    "opnsense" = @{Target="joseph@opnsense"; IP="192.168.1.1"; Name="OPNsense Router"}
    "wireguard" = @{Target="root@wireguard"; IP="192.168.1.50"; Name="WireGuard LXC"}
    "tailscale" = @{Target="root@tailscale"; IP="192.168.1.51"; Name="Tailscale LXC"}
    "omada" = @{Target="root@omada"; IP="192.168.1.52"; Name="Omada LXC"}
    "netbox" = @{Target="root@netbox"; IP="192.168.1.53"; Name="NetBox LXC"}
    "iventoy" = @{Target="root@iventoy"; IP="192.168.1.54"; Name="iVentoy LXC"}
    "docker" = @{Target="root@docker"; IP="192.168.1.55"; Name="Docker LXC"}
    "syncthing" = @{Target="root@syncthing"; IP="192.168.1.56"; Name="Syncthing LXC"}
}

# Default commands for info mode
$InfoCommands = @{
    "nas" = "hostname && cat /etc/os-release | head -2"
    "hp" = "hostname && nixos-rebuild list-generations | head -2 && uptime"
    "msi" = "hostname && nixos-rebuild list-generations | head -2 && uptime"
    "proxmox" = "hostname && pveversion && uptime"
    "opnsense" = "hostname && uname -r && uptime"
    "default" = "hostname && cat /etc/os-release | head -2 && uptime"
}

if (-not $HostMap.ContainsKey($HostAlias.ToLower())) {
    Write-Host "Unknown host alias: $HostAlias" -ForegroundColor Red
    Write-Host ""
    Write-Host "Available hosts:" -ForegroundColor Cyan
    foreach ($alias in $HostMap.Keys | Sort-Object) {
        $host = $HostMap[$alias]
        Write-Host "  $alias -> $($host.Name) ($($host.Target))" -ForegroundColor Gray
    }
    exit 1
}

$HostInfo = $HostMap[$HostAlias.ToLower()]
$SshTarget = $HostInfo.Target
$SshOptions = @("-o", "StrictHostKeyChecking=accept-new")

Write-Host "🔗 Connecting to $($HostInfo.Name)..." -ForegroundColor Blue

if ($Command) {
    # Execute specific command
    ssh @SshOptions $SshTarget $Command
} elseif ($Interactive) {
    # Interactive session
    ssh @SshOptions $SshTarget
} elseif ($Info) {
    # System info mode
    $InfoCmd = if ($InfoCommands.ContainsKey($HostAlias.ToLower())) { 
        $InfoCommands[$HostAlias.ToLower()] 
    } else { 
        $InfoCommands["default"] 
    }
    ssh @SshOptions $SshTarget $InfoCmd
} else {
    # Default: show system info
    $InfoCmd = if ($InfoCommands.ContainsKey($HostAlias.ToLower())) { 
        $InfoCommands[$HostAlias.ToLower()] 
    } else { 
        $InfoCommands["default"] 
    }
    ssh @SshOptions $SshTarget $InfoCmd
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Connection successful" -ForegroundColor Green
} else {
    Write-Host "❌ Connection failed" -ForegroundColor Red
    exit $LASTEXITCODE
}