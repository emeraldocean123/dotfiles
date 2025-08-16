# SSH Utilities

Cross-platform SSH connectivity and management scripts.

## Scripts

### test-ssh-connectivity.ps1
Test SSH connectivity to infrastructure hosts.

**Usage:**
```powershell
# Test all known hosts
.\test-ssh-connectivity.ps1 -All

# Test specific host
.\test-ssh-connectivity.ps1 -Target "user@hostname"

# Quiet mode (minimal output)
.\test-ssh-connectivity.ps1 -All -Quiet
```

### connect-host.ps1
Connect to infrastructure hosts using predefined aliases.

**Usage:**
```powershell
# Quick connection (shows system info)
.\connect-host.ps1 hp

# Interactive shell session
.\connect-host.ps1 msi -Interactive

# Execute specific command
.\connect-host.ps1 nas -Command "df -h"

# System info mode
.\connect-host.ps1 proxmox -Info
```

**Available host aliases:**
- `nas` - Synology NAS (192.168.1.10)
- `hp` - HP Laptop NixOS (192.168.1.104)
- `msi` - MSI Laptop NixOS (192.168.1.106)
- `proxmox` - Proxmox VE (192.168.1.40)
- `opnsense` - OPNsense Router (192.168.1.1)
- `wireguard` - WireGuard LXC (192.168.1.50)
- `tailscale` - Tailscale LXC (192.168.1.51)
- `omada` - Omada LXC (192.168.1.52)
- `netbox` - NetBox LXC (192.168.1.53)
- `iventoy` - iVentoy LXC (192.168.1.54)
- `docker` - Docker LXC (192.168.1.55)
- `syncthing` - Syncthing LXC (192.168.1.56)

## Requirements

- OpenSSH Client
- Unified SSH key (`~/.ssh/id_ed25519_unified`) configured for passwordless access
- Network connectivity to target hosts

## Integration

These scripts replace the individual connection utilities previously scattered across different repositories, providing a unified interface for SSH management.