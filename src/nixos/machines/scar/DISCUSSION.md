# TUPAC Kernel Issues Discussion

**Date:** March 6, 2026
**System:** tupac (Monster Tulpar T5 V23.2)
**Hostname:** tupac
**Current State:** Configuration deployed and verified

> **Note:** Configuration changes follow the [Nx Language Standard](docs/nx/standard.md)

---

## Overview

This document tracks ALL kernel-related issues discovered on the tupac system. All warnings are treated as errors.

---

## Kernel Issues Found

### 1. ACPI BIOS Errors

**Severity:** Medium
**Status:** BIOS Bug (cannot fix in software)

**Symptom:**
```
ACPI BIOS Error (bug): Could not resolve symbol [\_SB.PC00.MHBR], AE_NOT_FOUND (20240827/psargs-332)
ACPI: Ignoring error and continuing table load
ACPI BIOS Error (bug): Could not resolve symbol [\_SB.PTID.PBAR], AE_NOT_FOUND (20240827/dsfield-500)
```

**Root Cause:** BIOS firmware has invalid ACPI table references.

**Resolution:** Requires BIOS update from Monster/Tulpar vendor.

---

### 2. i915 VBT Warning + Kernel WARNING

**Severity:** High
**Status:** BIOS Bug - Cannot fix in software

**Symptom:**
```
i915 0000:00:02.0: [drm] Port B asks to use VBT vswing/preemph tables
WARNING: CPU: 5 PID: 1151 at drivers/gpu/drm/i915/display/intel_bios.c:2698 intel_bios_init+0x1480/0x19f0 [i915]
---[ end trace 0000000000000000 ]---
```

**Root Cause:** BIOS firmware bug - the Video BIOS Table (VBT) reports invalid DisplayPort info for Port B that doesn't exist in hardware.

**Fix Attempted (did NOT work):**
- Kernel parameter `i915.enable_dc=0`
- Modprobe config: `options i915 enable_guc=0`

**Resolution:** Requires BIOS update from Monster/Tulpar. See `docs/MONSTER_TULPAR_BIOS_REQUEST.md`

---

### 3. Intel WiFi 6E AX211 Capability Warning

**Severity:** Low
**Status:** Informational

**Symptom:**
```
iwlwifi 0000:00:14.3: capa flags index 4 larger than supported by driver
```

**Root Cause:** Driver doesn't support all hardware capabilities of this WiFi card.

**Resolution:** This is informational, not an error. Driver works but may have limited features.

---

### 4. Bluetooth "Bad flag given" Error

**Severity:** High
**Status:** NOT FIXED - Kernel parameters are IGNORED

**Symptom:**
```
btintel: unknown parameter 'force_bdaddr' ignored
btmtk: unknown parameter 'force_reset' ignored
Bluetooth: hci0: Bad flag given (0x1) vs supported (0x0)
```

**Root Cause:** 
1. The kernel parameters `btintel.force_bdaddr=1` and `btmtk.force_reset=1` are NOT supported by the current kernel modules
2. Intel AX201 Bluetooth firmware incompatibility with Linux kernel MGMT interface

**Fix Attempted (failed):**
- `btintel.force_bdaddr=1` - Parameter not recognized
- `btmtk.force_reset=1` - Parameter not recognized  
- `btusb.reset=1` - May help but didn't fix the root issue

**Next Steps:** Need to either:
- Find correct kernel parameters for this kernel version
- Upgrade/downgrade kernel
- Patch BlueZ for compatibility

---

### 5. Wireless Extensions (WEXT) Warning

**Severity:** Medium
**Status:** NOT FIXED

**Symptom:**
```
warning: `pool-4' uses wireless extensions which will stop working for Wi-Fi 7 hardware; use nl80211
```

**Root Cause:** wpa_supplicant using deprecated WEXT API instead of nl80211.

**Fix Attempted:**
- Added `wifi.backend = "wpa_supplicant"` in `config/networking.nix`
- Added `networking.wireless.extraConfig = "driver=nl80211"` in `config/networking.nix`

**Status:** Still not working. Need to investigate wpa_supplicant configuration.

---

### 6. Split Lock Detection

**Severity:** Low
**Status:** FIXED ✓

**Symptom (before):**
```
x86/split lock detection: #AC: crashing the kernel on kernel split_locks
```

**Fix Applied:**
- Kernel parameter `split_lock_detect=off`

**Verification:**
```
journalctl -k | grep "split lock"
x86/split lock detection: disabled
```

---

### 7. NVIDIA Open Source Driver

**Severity:** Informational
**Status:** Deployed

**Changes in `config/nvidia.nix`:**
- `open = true` - Using open-source driver
- `powerManagement.finegrained = false` - Disabled (not supported on mobile)

---

## Configuration Summary

| Issue | Fix Attempted | Status |
|-------|---------------|--------|
| ACPI errors | None | BIOS bug |
| i915 VBT | `i915.enable_dc=0`, `enable_guc=0` | BIOS bug - not fixed |
| WiFi capabilities | None | Informational |
| Bluetooth "Bad flag" | `btintel.force_bdaddr=1`, etc. | NOT FIXED - params ignored |
| Wireless WEXT | `wifi.backend = "wpa_supplicant"` | NOT FIXED |
| Split lock | `split_lock_detect=off` | FIXED ✓ |
| NVIDIA open driver | `open = true` | Deployed |

---

## Required Actions

1. **Remove invalid kernel parameters** from `config/kernel.nix`:
   - `btintel.force_bdaddr=1` (not supported)
   - `btmtk.force_reset=1` (not supported)

2. **Investigate Bluetooth fix** - Find correct parameters or patch for BlueZ

3. **Investigate Wireless WEXT** - Debug wpa_supplicant configuration

4. **Contact Monster/Tulpar** for BIOS update (see `docs/MONSTER_TULPAR_BIOS_REQUEST.md`)

---

## Verification Command

```bash
journalctl -k | grep -iE "(warning|error|unknown parameter|ignored)"
```
