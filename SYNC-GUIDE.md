# 🔄 Cross-Platform Shell Sync Guide

## **Current Status Overview**

### ✅ **PowerShell (Windows)**
- **Status**: Fully optimized and working (Version 2025.1)
- **Features**: Oh My Posh, PSReadLine, Terminal-Icons, robust aliases

### 🔄 **Debian System** 
- **Status**: Needs dotfiles bootstrap
- **Action Required**: Clone dotfiles and run bootstrap script

### 🔄 **NixOS Systems**
- **Status**: Home Manager configs updated, needs rebuild
- **Action Required**: Rebuild NixOS configuration

---

## **🚀 Quick Sync Commands**

### **For Debian System:**

```bash
cd ~ && git clone https://github.com/emeraldocean123/dotfiles.git ~/dotfiles
cd ~/dotfiles && chmod +x bootstrap.sh && ./bootstrap.sh
source ~/.bashrc && ll  # Test
```

### **For NixOS Systems:**

```bash
sudo nixos-rebuild switch --flake .#$(hostname)
source ~/.bashrc && ll  # Test
```

---

## **🔗 Unified Aliases (All Systems)**

| Alias | Description |
|-------|-------------|
| `ll` | Detailed listing with hidden files |
| `la` | Same as ll |
| `gs` | Git status |
| `ga` | Git add |
| `gc` | Git commit |
| `gp` | Git push |
| `gl` | Last 10 git commits |
| `gd` | Git diff |
| `..` | Go up one directory |

**Result**: Identical shell experience across Windows PowerShell, Debian, and NixOS! 🎯
