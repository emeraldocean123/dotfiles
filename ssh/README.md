# SSH Configuration

This directory contains SSH client configuration that should be synced across machines.

## Files

- **`config`** - SSH client configuration with host definitions

## SSH Config Contents

The SSH config includes definitions for:
- GitHub authentication
- NixOS laptops (HP, MSI)
- Proxmox virtualization host
- LXC containers (WireGuard, Tailscale, Omada, NetBox, etc.)
- Synology NAS
- OPNsense router

## Security Notes

⚠️ **IMPORTANT**: This directory contains SSH configuration but **NOT SSH keys**.

- ✅ SSH config file - Safe to sync (contains host definitions)
- ❌ SSH private keys - Never add to version control
- ❌ SSH public keys - Can be regenerated, don't need to sync

## Installation

The SSH config is installed by the dotfiles bootstrap scripts. To manually install:

### Windows
```powershell
Copy-Item "ssh/config" "$env:USERPROFILE/.ssh/config" -Force
```

### Linux/macOS
```bash
cp ssh/config ~/.ssh/config
chmod 600 ~/.ssh/config
```

## Key Management

SSH keys should be generated on each machine:
```bash
# Generate unified key
ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/id_ed25519_unified

# Generate GitHub-specific key
ssh-keygen -t ed25519 -C "your-email@example.com" -f ~/.ssh/id_ed25519_github
```