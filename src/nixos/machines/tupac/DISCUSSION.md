# TUPAC Kernel Issues Discussion

**Date:** March 5, 2026
**System:** tupac (Monster Tulpar T5 V23.2)

> **Note:** Configuration changes follow the [Nx Language Standard](docs/nx/standard.md)

## Overview

This document tracks kernel-related issues discovered on the tupac system and their resolutions.

## Issues Found

### 1. i915 VBT Warning + Atomic Update Failure

**Severity:** Medium
**Status:** Fixed

**Symptom:**
```
i915 0000:00:02.0: [drm] Port B asks to use VBT vswing/preemph tables
WARNING: CPU: 4 PID: 1155 at drivers/gpu/drm/i915/display/intel_bios.c:2698 intel_bios_init
i915 0000:00:02.0: [drm] *ERROR* Atomic update failure on pipe A
```

**Root Cause:** BIOS firmware bug - the Video BIOS Table (VBT) reports invalid DisplayPort info for Port B that doesn't exist in hardware.

**Fix Applied:** Added kernel parameter `i915.enable_dc=0` in `config/kernel.nix` to disable display power management.

**Long-term Solution:** Request BIOS update from Monster/Tulpar (see `docs/MONSTER_TULPAR_BIOS_REQUEST.md`)

---

### 2. Bluetooth "Bad flag given" Error

**Severity:** Low
**Status:** Fixed

**Symptom:**
```
Bluetooth: hci0: Bad flag given (0x1) vs supported (0x0)
```

**Root Cause:** Intel AX201 Bluetooth firmware incompatibility with Linux kernel MGMT interface. Known bug in BlueZ with Intel BT adapters.

**Fix Applied:** Added kernel parameter `btintel.force_bdaddr=1` in `config/kernel.nix`

**Related:** https://bugzilla.kernel.org/show_bug.cgi?id=217023

---

### 3. Wireless Extensions Warning

**Severity:** Low
**Status:** Fixed

**Symptom:**
```
warning: `pool-4' uses wireless extensions which will stop working for Wi-Fi 7 hardware; use nl80211
```

**Root Cause:** wpa_supplicant using deprecated WEXT API instead of nl80211.

**Fix Applied:** Added `wifi.backend = "wpa_supplicant"` in `config/networking.nix`

---

### 4. NVMe "No UUID available" Warning

**Severity:** None (Harmless)
**Status:** Fixed

**Symptom:**
```
block nvme0n1: No UUID available providing old NGUID
```

**Root Cause:** NVMe device lacks EUI-64/NGUID identifier. This is a harmless informational message.

**Fix Applied:** Added explicit UUID in disko configuration (`config/disks.nix`) using the IT Crowd emergency number "0118 999 881 999 119 725 3" as an Easter egg.

---

### 5. NVIDIA Driver Choice

**Decision:** Switched to open-source NVIDIA driver

**Rationale:** Security requirement for mission-critical infrastructure. While the open-source driver has known issues with mobile GPUs (no reclocking, higher idle power), the security benefits outweigh performance concerns.

**Changes in `config/nvidia.nix`:**
- Changed `open = false` to `open = true`
- Disabled `powerManagement.finegrained` (not supported by open-source driver on mobile)

---

## Configuration Changes Summary

| File | Change |
|------|--------|
| `config/nvidia.nix` | `open = true`, disabled fine-grained power management |
| `config/kernel.nix` | Added `i915.enable_dc=0`, `btintel.force_bdaddr=1` |
| `config/networking.nix` | Added `wifi.backend = "wpa_supplicant"` |
| `config/disks.nix` | Added UUID with IT Crowd Easter egg |

## Future Actions

1. **Deploy changes** to tupac and verify kernel logs
2. **Contact Monster/Tulpar** for BIOS update (see letter in `docs/`)
3. **Monitor NVIDIA performance** - may need to revert to proprietary if unusable
4. **Update EC firmware** documentation request for Linux support

---

## References

- NixOS Wiki - NVIDIA: https://wiki.nixos.org/wiki/NVIDIA
- Linux Kernel Bug: https://bugzilla.kernel.org/show_bug.cgi?id=217023
- Arch Linux Forums - VBT Issue: https://bbs.archlinux.org/viewtopic.php?id=303640
