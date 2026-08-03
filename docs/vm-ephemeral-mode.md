# VM Ephemeral Mode - Technical Documentation

## Overview

NiXium VMs support an ephemeral mode for external runs (e.g., `nix run github:Arcanyx-org/NiXium#nixos-test-vm`) that avoids creating persistent disk overlay files on the user's system.

## How It Works

### QEMU Snapshot Mode

The implementation uses QEMU's `-snapshot` flag, which provides automatic cleanup through the `unlink()` syscall pattern:

1. QEMU creates a temporary COW (Copy-on-Write) overlay file: `/var/tmp/nix-vm.XXXXX/vl.RANDOM`
2. QEMU **immediately calls `unlink()` on the file** while keeping the file descriptor open
3. The file is marked as `(deleted)` in the filesystem - it doesn't appear in `ls` or `find` output
4. The kernel reserves disk space for the file but makes it inaccessible to other processes
5. When QEMU exits (gracefully or via crash/kill), the kernel automatically frees the disk space

**Verified behavior:**
```bash
# File appears in /proc/PID/fd with (deleted) marker
$ ls -l /proc/<qemu-pid>/fd/8
lrwx------ 1 user users 64 Apr 5 06:19 8 -> /var/tmp/nix-vm.XXX/vl.PI8FN3 (deleted)

# But doesn't appear in directory listing
$ find /var/tmp/nix-vm.XXX -type f
# (no output)

# Disk space is auto-freed when QEMU exits, even on SIGKILL
```

### Why /var/tmp Instead of /tmp?

**The ephemeral mode uses `/var/tmp` as TMPDIR, not `/tmp`:**

| Directory | Type | Concerns |
|-----------|------|----------|
| `/tmp` | Often tmpfs (RAM) | QEMU overlay files consume RAM → OOM on low-RAM systems |
| `/var/tmp` | Disk-backed | Uses actual disk space → No RAM pressure |

System administrators expect `/var/tmp` to contain temporary files that may persist across reboots (cleaned by tmpfiles.d policies), making it more appropriate for QEMU's deleted-but-open files.

### Cleanup Guarantees

**Automatic cleanup happens even when:**
- QEMU crashes (segfault, assertion failure)
- Process is killed with `SIGKILL` (kill -9)
- Parent process is terminated (timeout, user interrupt)
- System loses power (on next boot, kernel reclaims space for deleted files)

**Why it's safe:** The Linux kernel automatically frees disk space for deleted files when the last file descriptor closes. Since QEMU is the only process with an open FD to the deleted overlay file, cleanup is guaranteed when QEMU exits.

## Disk Path Resolution

The VM runner uses a 4-tier priority system:

### Tier 1: User Override (Highest Priority)
```bash
export NIX_DISK_IMAGE="/custom/path.qcow2"
nix run .#nixos-test-vm
# Uses /custom/path.qcow2, persistent mode (no snapshot)
```

**Behavior:** User has full control, changes persist.

### Tier 2: Development Mode
```bash
# Inside NiXium repository with FLAKE_ROOT set
nix run .#nixos-test-vm
# Uses $FLAKE_ROOT/nixos-test-vm.qcow2, persistent mode
```

**Behavior:** Disk stored in repository root, changes persist across runs (for development/testing).

### Tier 3: Cached Base Disk
```bash
# External run with pre-created cache
~/.cache/nixium/vm-bases/nixos-base-8G-vm.qcow2 exists
nix run github:Arcanyx-org/NiXium#nixos-test-vm
# Uses cached base with snapshot mode (ephemeral)
```

**Behavior:** Fast startup, base disk never modified, QEMU overlay auto-deleted.

**How to create cache:**
```bash
mkdir -p ~/.cache/nixium/vm-bases
temp=$(mktemp)
qemu-img create -f raw "$temp" 8G
mkfs.ext4 -L nixos "$temp" -q -F
qemu-img convert -f raw -O qcow2 "$temp" \
    ~/.cache/nixium/vm-bases/nixos-base-8G-vm.qcow2
rm "$temp"
```

### Tier 4: Ephemeral Base Disk (Fallback)
```bash
# External run, no cache
nix run github:Arcanyx-org/NiXium#nixos-test-vm
# Creates /var/tmp/nixium-vm-<PID>-<RANDOM>.qcow2 on first run
# Uses snapshot mode (ephemeral)
```

**Behavior:**
- Base disk created on-demand in `/var/tmp` (~7.7MB for 8GB virtual disk)
- Base disk **persists across VM runs** (acts as implicit cache until reboot/cleanup)
- QEMU overlay is still ephemeral (deleted-but-open file pattern)
- Manual cleanup: `rm /var/tmp/nixium-vm-*.qcow2`

**Why persist the base?** Creating the base disk takes ~2 seconds. Reusing it makes subsequent runs faster. System tmpfiles.d policies will eventually clean `/var/tmp`, or users can clean manually.

## Files Created by VMs

When running a NiXium VM, the following files are created:

| File | Location | Size | Persistent? | Purpose |
|------|----------|------|-------------|---------|
| Base disk | `/var/tmp/nixium-vm-*.qcow2` or cache | ~7.7MB | Yes (until manual cleanup or reboot) | Reusable ext4 filesystem |
| QEMU overlay | `/var/tmp/nix-vm.*/vl.*` | Grows with writes | **No (deleted-but-open)** | COW overlay for VM changes |
| VM tmpdir | `/var/tmp/nix-vm.*/` | Small | Yes (dir persists) | xchg directory for host↔guest file sharing |

**Total persistent footprint:** ~7.7MB base disk + small tmpdir (directories only)

**Disk space used during VM run:** Base disk + overlay growth (freed automatically on exit)

## User Communication

When running VMs externally, users should be informed:

### In README or Documentation

> **VM Disk Storage:**
> 
> When running NiXium VMs externally (e.g., `nix run github:Arcanyx-org/NiXium#nixos-test-vm`), 
> a small base disk (~7.7MB) is created in `/var/tmp/nixium-vm-*.qcow2` for better performance.
> 
> **This base disk is reusable across runs and does not grow.** All VM changes are written to 
> ephemeral overlay files that are automatically deleted when the VM exits.
> 
> **To clean up manually:**
> ```bash
> rm /var/tmp/nixium-vm-*.qcow2
> rm -rf /var/tmp/nix-vm.*
> ```
> 
> **For faster startup, create a persistent cache:**
> ```bash
> mkdir -p ~/.cache/nixium/vm-bases
> # (See docs/vm-ephemeral-mode.md for cache creation instructions)
> ```

### In Error Messages (Optional)

If disk creation fails (e.g., `/var/tmp` full):

```
Error: Failed to create VM base disk in /var/tmp

Disk space issue? Try:
  1. Free space in /var/tmp, or
  2. Set a custom location: export NIX_DISK_IMAGE="/path/to/disk.qcow2"
  3. Clean old VM files: rm /var/tmp/nixium-vm-*.qcow2

Current /var/tmp usage: <show df output>
```

## Implementation Reference

### Shell Script Pattern

```bash
#!/usr/bin/env bash
set -e

VM_NAME="nixos-example-vm"
VM_PATH="/nix/store/...-nixos-vm"
FLAKE_ROOT="${FLAKE_ROOT:-}"

# Tier 1: User override
if [ -n "${NIX_DISK_IMAGE:-}" ]; then
	EPHEMERAL=false
# Tier 2: Development mode	
elif [ -n "$FLAKE_ROOT" ] && [ -d "$FLAKE_ROOT" ]; then
	export NIX_DISK_IMAGE="$FLAKE_ROOT/$VM_NAME.qcow2"
	EPHEMERAL=false
# Tier 3 & 4: External mode
else
	CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/nixium/vm-bases"
	BASE_DISK="$CACHE_DIR/nixos-base-8G-vm.qcow2"
	
	if [ ! -f "$BASE_DISK" ]; then
		# Tier 4: Create ephemeral base
		BASE_DISK="/var/tmp/nixium-vm-$$-$RANDOM.qcow2"
		
		if [ ! -f "$BASE_DISK" ]; then
			temp=$(mktemp)
			qemu-img create -f raw "$temp" 8G >/dev/null 2>&1
			mkfs.ext4 -L nixos "$temp" -q -F
			qemu-img convert -f raw -O qcow2 "$temp" "$BASE_DISK"
			rm "$temp"
		fi
	fi
	
	export NIX_DISK_IMAGE="$BASE_DISK"
	EPHEMERAL=true
fi

# Apply ephemeral settings
if ${EPHEMERAL:-false}; then
	export QEMU_OPTS="${QEMU_OPTS:+$QEMU_OPTS }-snapshot"
	export TMPDIR="${TMPDIR:-/var/tmp}"
fi

exec "$VM_PATH/bin/run-nixos-vm" "$@"
```

### Nix Implementation

See `lib/mkVmRunner/default.nix` for the canonical implementation.

## Testing

Verify ephemeral mode works correctly:

```bash
# External run test
export HOME=/tmp/test-home
unset FLAKE_ROOT
unset NIX_DISK_IMAGE

# Get base disk md5
BASE=/var/tmp/nixos-test-vm-*.qcow2
md5sum $BASE

# Run VM
nix run github:Arcanyx-org/NiXium#nixos-test-vm -- -nographic

# Verify base unchanged
md5sum $BASE  # Should match

# Verify no overlay files
find /var/tmp -name "vl.*"  # Should be empty
```

## FAQ

**Q: What if /var/tmp is full?**
A: Set `NIX_DISK_IMAGE` to a custom location with available space, or clean old files.

**Q: Can I disable ephemeral mode?**
A: Yes, set `NIX_DISK_IMAGE="/path/to/persistent.qcow2"` before running the VM.

**Q: What about RAM usage?**
A: QEMU overlay files use disk space in `/var/tmp`, not RAM. No OOM risk.

**Q: How do I clean up all VM files?**
A: `rm /var/tmp/nixium-vm-*.qcow2 && rm -rf /var/tmp/nix-vm.*`

**Q: Does the base disk grow over time?**
A: No, the base disk remains ~7.7MB. QEMU overlays grow during runtime but are deleted on exit.

**Q: What happens on system crash/power loss?**
A: On next boot, the kernel reclaims disk space for deleted-but-open files automatically.

## References

- QEMU snapshot mode: https://www.qemu.org/docs/master/system/invocation.html#hxtool-4
- Linux deleted-but-open files: https://unix.stackexchange.com/a/104569
- Kernel file descriptor cleanup: `fs/file.c` in Linux source
