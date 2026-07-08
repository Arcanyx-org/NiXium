<!-- SUMMARY: Disk strategy portability — use TMPDIR fallback instead of hardcoded /var/tmp, correct priority order for 3-mode disk strategy. LOAD WHEN: Working on VM disk images, QEMU disk paths, or portability concerns. SKIP WHEN: Not working on VM disk or portability issues. -->

# Quest: Disk Strategy Portability and Priority

## Metadata

| Field | Value |
|-------|-------|
| **Status** | Decided |
| **Priority** | High |
| **Created** | 2026-04-13 |
| **Updated** | 2026-04-13 |
| **Assigned** | TBD |

## Problem

Agents working on NiXium's VM library lack context about portability concerns for temporary directories and the correct priority order for the 3-mode disk strategy. Without this context, agents hardcode `/var/tmp` (which doesn't exist on macOS or non-FHS systems) and order the disk mode checks suboptimally.

## The Anti-Pattern: Hardcoded `/var/tmp`

```sh
# WRONG ❌ — /var/tmp doesn't exist on macOS or some non-FHS systems
export NIX_DISK_IMAGE="/var/tmp/nixium-vm-${VM_NAME}.qcow2"
```

## The Anti-Pattern: Wrong Priority Order

```sh
# WRONG ❌ — NIX_DISK_IMAGE checked first, but FLAKE_ROOT is always set
# when running from the repo, so user overrides are silently ignored
if [ -n "${NIX_DISK_IMAGE:-}" ]; then
	# Mode 2: User override
	:
elif [ -n "${FLAKE_ROOT:-}" ] && [ -d "$FLAKE_ROOT" ]; then
	# Mode 1: Dev
	export NIX_DISK_IMAGE="${MODULE_PATH}/${VM_NAME}.qcow2"
else
	# Mode 3: Ephemeral
fi
```

## The Correct Pattern: TMPDIR Fallback with Warning

```sh
if [ -d "${FLAKE_ROOT:-}" ]; then
	# Mode 1: Dev — FLAKE_ROOT is valid directory, persist disk next to module
	export NIX_DISK_IMAGE="${MODULE_PATH}/${VM_NAME}.qcow2"
elif [ -n "${NIX_DISK_IMAGE:-}" ]; then
	# Mode 2: User override — explicit disk location
	# Also catches stale FLAKE_ROOT (set but not a directory)
	:
else
	# Mode 3: Ephemeral — use TMPDIR if set, fall back to /var/tmp (FHS)
	# Warn if TMPDIR=/tmp since it may be tmpfs/RAM-backed
	if [ "${TMPDIR:-/var/tmp}" = "/tmp" ]; then
		echo "WARNING: TMPDIR is /tmp, which may be tmpfs (RAM-backed)." >&2
		echo "  Large VM disk overlays may cause OOM. Consider setting TMPDIR" >&2
		echo "  to a disk-backed directory." >&2
	fi
	export NIX_DISK_IMAGE="${TMPDIR:-/var/tmp}/nixium-vm-${VM_NAME}.qcow2"
	export QEMU_OPTS="${QEMU_OPTS:+${QEMU_OPTS} }-snapshot"
fi
```

## Why This Priority Order

1. **FLAKE_ROOT first**: When running from the repository (the common case), `FLAKE_ROOT` is always set by direnv/nix develop. Checking it first avoids wasting CPU cycles on unnecessary checks.
2. **NIX_DISK_IMAGE second**: Explicit user override. Also catches the edge case where `FLAKE_ROOT` is set but points to a non-existent directory (stale env var).
3. **Ephemeral fallback**: Neither condition met — use `${TMPDIR:-/var/tmp}` for portability.

## Why `${TMPDIR:-/var/tmp}`

| System | `TMPDIR` | Result | Disk-backed? |
|--------|----------|--------|-------------|
| Linux (default) | unset | `/var/tmp` | Usually yes (FHS convention) |
| Linux (custom) | set by user | User's choice | User's responsibility |
| macOS | set by system | `/var/folders/.../T/` | Yes (root filesystem) |
| NixOS tmpfs root | unset | `/var/tmp` (tmpfs) | No, but that's admin's config |

We cannot guarantee disk-backed storage on every system — that's the administrator's responsibility. What we can do is follow the system's convention and warn when it looks problematic.

## How to Address

- Add this pattern to `.opencode/context/` as a portability standard
- Add a rule: "Never hardcode `/var/tmp` or `/tmp` — always use `${TMPDIR:-/var/tmp}` with a warning when TMPDIR=/tmp"

## Related Quests

- [env-vars-over-command-construction](../env-vars-over-command-construction/quest.md) — Environment variables over command construction
- [nix-repl-vm-testing](../nix-repl-vm-testing/quest.md) — VM testing from nix repl