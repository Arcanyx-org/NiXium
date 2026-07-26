# Scar

Role: Personal Portable System, Workstation and Thin Client

ASUS ROG (Coffee Lake) Laptop with GTX 1060

## System Specifications

- **CPU:** Intel Core i7-8750H (Coffee Lake, 6C/12T, 2.20GHz)
- **GPU:** Intel UHD Graphics 630 (Coffee Lake GT2) + NVIDIA GeForce GTX 1060 (GP106)
- **WiFi/BT:** Intel Wireless-AC 9560 160MHz
- **Storage:** ADATA SP900 SSD 238.5GB (SATA)
- **RAM:** 8GB DDR4

## Known Issues & Fixes

| Issue | Status | Fix |
|-------|--------|------|
| CPU Vulnerabilities (MDS/MMIO) | Fixed | SMT disabled, mitigations active |
| NVIDIA GTX 1060 Driver | Fixed | Using legacy 580.xx driver |
| Secure Boot | Enrolled | Keys enrolled via `sbctl`; enable in UEFI firmware and reboot to enforce |
| ACPI asus_wmi fan curves | Cosmetic | BIOS bug, no fix available |

## Configuration Files

- `config/security.nix` - SMT disabled, kernel hardening
- `config/nvidia.nix` - NVIDIA GTX 1060 legacy driver
- `config/kernel.nix` - Kernel parameters and modules
- `config/networking.nix` - NetworkManager and firewall
- `config/disks.nix` - Disko configuration
