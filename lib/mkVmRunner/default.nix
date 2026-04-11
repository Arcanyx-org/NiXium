###! mkVmRunner - VM Runner Script Generator (FUTURE IMPLEMENTATION)
###!
###! Purpose: Generate shell wrapper scripts for NixOS VMs that handle disk path resolution
###! and enable ephemeral mode for external runs.
###!
###! Problem: Running VMs externally (e.g., `nix run github:Arcanyx-org/NiXium#nixos-vm-test`)
###! fails because the wrapper script uses $FLAKE_ROOT or ${modulePath} to construct disk paths,
###! which are unset when running from outside the repository.
###!
###! Current Solution (Implemented Inline in VM Modules):
###! Each VM module now has inline 3-tier priority logic:
###!   1. FLAKE_ROOT (development mode) - persistent disk in repo root
###!   2. NIX_DISK_IMAGE (user override) - user-specified path
###!   3. Ephemeral mode - auto-created base disk with QEMU snapshot
###!
###! This file documents the FUTURE implementation plan for when we're ready to extract
###! the common pattern into a reusable library function.
###!
###! Usage (Future):
###!   apps.nixos-vm-example = {
###!     type = "app";
###!     program = lib.getExe (self.lib.mkVmRunner pkgs {
###!       name = "nixos-vm-example";
###!       vmPath = vm-config.config.system.build.vm;
###!       diskSize = "8G";  # optional, defaults to 8G
###!     });
###!   };
###!
###! Disk Path Resolution (Priority Order):
###!
###! Priority 1: FLAKE_ROOT (Development Mode)
###!   Condition: $FLAKE_ROOT is set and is a valid directory
###!   Disk Path: $FLAKE_ROOT/$VM_NAME.qcow2
###!   Behavior: Persistent disk, changes saved across runs
###!   Use Case: Repository contributors developing/testing VMs
###!   Why First: Most common case in repository, saves CPU cycles
###!
###! Priority 2: NIX_DISK_IMAGE (User Override)
###!   Condition: User explicitly sets NIX_DISK_IMAGE environment variable
###!   Disk Path: User-specified value (validated for sanity)
###!   Behavior: Persistent disk at custom location
###!   Use Case: Users wanting persistent storage in specific location
###!   Validation: Check if parent directory exists and is writable
###!
###! Priority 3: Ephemeral Mode (External Runs)
###!   Condition: FLAKE_ROOT not set, NIX_DISK_IMAGE not set
###!   Disk Path: Cache or /var/tmp base disk
###!   Behavior: Read-only base + ephemeral QEMU overlay (auto-deleted)
###!   Use Case: External users trying VMs without persistent state
###!
###!   Sub-priority 3a: Cached Base Disk
###!     Path: $XDG_CACHE_HOME/nixium/vm-bases/nixos-vm-base-${diskSize}.qcow2
###!     If exists: Use cached base (fast startup)
###!
###!   Sub-priority 3b: Ephemeral Base Disk
###!     Path: /var/tmp/nixium-vm-$PID-$RANDOM.qcow2
###!     If no cache: Create on-demand (~7.7MB, persists until reboot/cleanup)
###!     Reusable: Acts as implicit cache across runs
###!
###! Ephemeral Mode Technical Details:
###!
###! QEMU Snapshot Mode (-snapshot flag):
###!   - QEMU creates temporary COW overlay: /var/tmp/nix-vm.XXXXX/vl.RANDOM
###!   - QEMU immediately calls unlink() while keeping file descriptor open
###!   - File marked (deleted) in filesystem - invisible to ls/find
###!   - Kernel reserves disk space but file is inaccessible to other processes
###!   - When QEMU exits (gracefully/crash/SIGKILL), kernel auto-frees space
###!
###!   Verified: The unlink() syscall removes the directory entry but the inode
###!   remains allocated as long as a process has the file open. When QEMU exits
###!   (even via SIGKILL, crash, or power loss), the kernel automatically reclaims
###!   the disk space. This is a fundamental Linux filesystem guarantee.
###!
###! Why /var/tmp Instead of /tmp:
###!   /tmp    - Often tmpfs (RAM-backed) → QEMU overlay consumes RAM → OOM risk
###!   /var/tmp - Disk-backed → Uses actual disk space → No RAM pressure
###!
###! Cleanup Guarantees (Kernel-Level):
###!   - QEMU crash (segfault): ✓ Kernel frees space when process dies
###!   - SIGKILL (kill -9): ✓ Kernel frees space when FD closes
###!   - xkill / forced termination: ✓ Same as SIGKILL
###!   - Power loss: ✓ Kernel reclaims space for deleted files on next boot
###!   - Parent timeout: ✓ QEMU child process cleanup handled by kernel
###!
###! Files Created:
###!   | File              | Location                  | Size   | Persistent? | Purpose              |
###!   |-------------------|---------------------------|--------|-------------|----------------------|
###!   | Base disk         | /var/tmp/nixium-vm-*.qcow2| ~7.7MB | Yes*        | Reusable ext4 fs     |
###!   | QEMU overlay      | /var/tmp/nix-vm.*/vl.*    | Varies | No (deleted)| COW overlay (ephemeral)|
###!   | VM tmpdir         | /var/tmp/nix-vm.*/        | Small  | Yes (dir)   | Host↔guest xchg      |
###!
###!   *Base disk persists until manual cleanup or system reboot (tmpfiles.d)
###!
###! User Communication:
###!   See docs/vm-ephemeral-mode.md for user-facing documentation about:
###!   - What files are created and why
###!   - How to clean up manually
###!   - How to create persistent cache
###!   - Disk space usage
###!
###! Implementation Notes (For Future mkVmRunner Function):
###!
###! Shell Script Pattern:
###!   1. Check FLAKE_ROOT first (most common in repo - save CPU cycles)
###!   2. Check NIX_DISK_IMAGE (user override with validation)
###!   3. Check cache, fallback to ephemeral base
###!   4. Apply ephemeral settings if not in dev mode
###!   5. Execute VM with proper environment
###!
###! Path Validation for NIX_DISK_IMAGE:
###!   - Convert relative paths to absolute: [ "${path:0:1}" = "/" ] || path="$(pwd)/$path"
###!   - Verify parent directory exists: [ -d "$(dirname "$path")" ]
###!   - Check if parent is writable: [ -w "$(dirname "$path")" ]
###!   - Validate existing path is regular file: [ ! -e "$path" ] || [ -f "$path" ]
###!   - Provide helpful error messages with suggested fixes
###!
###! Base Disk Creation:
###!   temp=$(mktemp)
###!   qemu-img create -f raw "$temp" ${diskSize} >/dev/null 2>&1
###!   mkfs.ext4 -L nixos "$temp" -q -F
###!   qemu-img convert -f raw -O qcow2 "$temp" "$BASE_DISK"
###!   rm "$temp"
###!
###!   Why this order? mkfs.ext4 needs raw file, then convert to qcow2 format.
###!
###! Environment Variables Set:
###!   NIX_DISK_IMAGE - Path to base disk
###!   QEMU_OPTS      - Add "-snapshot" flag in ephemeral mode
###!   TMPDIR         - Set to /var/tmp for disk-backed temp files
###!
###! Error Handling:
###!   - /var/tmp full: Show df output, suggest NIX_DISK_IMAGE override
###!   - qemu-img fails: Show command that failed, suggest manual creation
###!   - Invalid NIX_DISK_IMAGE: Show validation error, suggest fixes
###!
###! Testing Checklist (Before Extracting to Library):
###!   [ ] FLAKE_ROOT set → Uses $FLAKE_ROOT/$VM_NAME.qcow2, persistent
###!   [ ] NIX_DISK_IMAGE set → Uses custom path, persistent
###!   [ ] External run (no FLAKE_ROOT) → Creates /var/tmp base, ephemeral overlay
###!   [ ] VM crash/SIGKILL → Overlay auto-deleted, base unchanged (verify md5)
###!   [ ] Multiple sequential runs → Base disk reused, md5 unchanged
###!   [ ] Cache creation → Manual cache in XDG_CACHE_HOME works
###!
###! Why NOT Implemented Yet:
###!   - Pattern needs battle testing across different VMs
###!   - Only 3 similar examples (vim, nvim, appimage) - not enough data
###!   - Edge cases may exist (different disk sizes, special configs)
###!   - Better to wait for more usage patterns before abstracting
###!   - Current inline implementation is transparent and easy to debug
###!
###! When to Implement:
###!   - After 6+ months of production use
###!   - When we have 5+ VM modules using the same pattern
###!   - When we identify and fix all edge cases
###!   - When the pattern is truly stable and unchanging
###!
###! Current Implementation Location:
###!   - src/nixos/users/users/kreyren/home/modules/editors/vim/default.nix (lines ~156-190)
###!   - src/nixos/users/users/kreyren/home/modules/editors/nvim/default.nix (lines ~140-174)
###!   - src/nixos/modules/programs/appimage/default.nix (lines ~234-310)
###!
###! Migration Strategy (Future):
###!   1. Implement mkVmRunner following this spec
###!   2. Test with ONE VM module first
###!   3. Verify all 6 test scenarios pass
###!   4. Gradually migrate other VMs
###!   5. Keep inline version as reference for 1 release cycle
###!   6. Remove inline implementations when library is proven stable
###!
###! Open Questions Resolved:
###!   Q: Should we pre-create cache in a separate derivation?
###!   A: No - document manual creation. Avoids unused derivations.
###!
###!   Q: Disk size configurable per-VM?
###!   A: Yes - make it a parameter with 8G default (same as NixOS VMs).
###!
###!   Q: Cache invalidation strategy?
###!   A: Manual cleanup only. Base disk is version-agnostic ext4.
###!
###!   Q: What if /var/tmp is full?
###!   A: Let it fail with clear error, suggest NIX_DISK_IMAGE override.
###!
###!   Q: What about RAM usage with /var/tmp?
###!   A: No RAM concerns - /var/tmp is disk-backed, QEMU uses disk space not RAM.
###!
###!   Q: Cleanup on crash/kill?
###!   A: Kernel handles automatically via unlink() + open FD pattern. Verified.
###!
###! Future Enhancements (NOT for initial implementation):
###!   - Automatic cache creation on first run
###!   - XDG tmpfiles.d integration for cleanup
###!   - Progress indicator for base disk creation
###!   - Shared base disk pool with reference counting
###!   - Disk size auto-detection based on VM config
###!
###! References:
###!   - QEMU snapshot: https://www.qemu.org/docs/master/system/invocation.html
###!   - Linux unlink() behavior: man 2 unlink
###!   - Deleted-but-open files: https://unix.stackexchange.com/a/104569
###!   - Kernel file descriptor cleanup: fs/file.c in Linux source
###!   - User docs: docs/vm-ephemeral-mode.md
###!
###! Research Findings (2026-04-05):
###!   - QEMU snapshot mode confirmed to use unlink() immediately after creating overlay
###!   - Verified via /proc/PID/fd/ showing files marked as "(deleted)"
###!   - Tested SIGKILL cleanup - kernel reclaims space automatically
###!   - Base disk size: 7.7MB for 8GB virtual disk (qcow2 compression)
###!   - VM boot time: ~5 seconds to systemd with ephemeral mode
###!   - Base disk creation time: ~2 seconds for 8GB disk

###! DO NOT IMPLEMENT YET - This is documentation only
###! Current VMs use inline implementation for battle testing
###! Revisit in 6+ months when pattern is proven stable
