# Tupáááč~

Role: Personal Portable System, Workstation and Thin Client

Tulpar T5 V23.2 15.6" with RTX4060 - https://www.tulparnotebook.de/t-serie-t5-v-23-2

## System Specifications

- **CPU:** Intel Alder Lake (likely i7-12700H or similar)
- **GPU:** Intel UHD Graphics (Alder Lake-P GT1) + NVIDIA GeForce RTX 4060 Mobile
- **WiFi/BT:** Intel Wi-Fi 6E AX211
- **Storage:** NVMe SSD (SOLIDIGM)
- **RAM:** DDR5 (typical for this model)

## Known Issues & Fixes

| Issue | Status | Fix |
|-------|--------|-----|
| i915 VBT Warning | Needs BIOS Update | `i915.enable_dc=0` kernel param deployed; VBT issue requires vendor BIOS update |
| i915 Kernel Crash | Fixed | `options i915 enable_guc=0` modprobe config deployed |
| Bluetooth "Bad flag" | Works | Kernel params loaded; Bluetooth is functional |
| Wireless WEXT Warning | Partial | `wifi.backend = "wpa_supplicant"` deployed; nl80211 config may need reboot |
| NVMe UUID Warning | Harmless | Ignored - known kernel issue with no fix needed |
| Split Lock Detection | Fixed (needs reboot) | `split_lock_detect=off` kernel param added |
| NVIDIA Proprietary Driver | Changed | Using open-source driver (`open = true`) |

## Configuration Files

- `config/kernel.nix` - Kernel parameters including workarounds
- `config/nvidia.nix` - NVIDIA driver configuration
- `config/networking.nix` - NetworkManager and wireless config
- `config/disks.nix` - Disko configuration with UUID fixes
- `config/hardware-acceleration.nix` - VAAPI/VA-driver config

## BIOS Update

See `docs/MONSTER_TULPAR_BIOS_REQUEST.md` for the BIOS update request letter sent to Monster/Tulpar support.

## TODO

- [ ] Rework experiments into modules
- [ ] Verify all kernel warnings are resolved after deployment
- [ ] Monitor NVIDIA open-source driver performance
