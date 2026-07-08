<!-- SUMMARY: Use environment variables instead of constructing QEMU command lines dynamically in shell scripts. LOAD WHEN: Writing VM runner scripts, QEMU argument construction, or shell script command building. SKIP WHEN: Not working on VM or shell command construction. -->

# Quest: Environment Variables Over Command Construction

## Metadata

| Field | Value |
|-------|-------|
| **Status** | Decided |
| **Priority** | High |
| **Created** | 2026-04-13 |
| **Updated** | 2026-04-13 |
| **Assigned** | TBD |

## Problem

Agents working on NiXium's VM library lack context about how the NixOS VM runner (`run-nixos-vm`) works. Without this context, agents construct QEMU command lines dynamically in shell scripts, inventing Bash arrays, `set --` patterns, IFS manipulation, and `${var:+"$var"}` patterns — all to solve a problem that doesn't exist.

## The Anti-Pattern: Constructing QEMU Arguments

```sh
# WRONG ❌ — Building QEMU arguments dynamically
declare -a QEMU_ARGS=( "-m" "2048" "-smp" "2" )
if [ -n "$DISK" ]; then
	QEMU_ARGS+=( "-drive" "file=$DISK,format=qcow2" )
fi
if [ -n "$GPU" ]; then
	QEMU_ARGS+=( "-device" "vfio-pci,host=$GPU" )
fi
exec qemu-system-x86_64 "${QEMU_ARGS[@]}"
```

This approach requires Bash arrays (violating POSIX sh), is hard to maintain, and reinvents what the NixOS VM runner already provides.

## The Correct Pattern: Set Environment Variables, Execute Runner

The NixOS VM runner (`run-nixos-vm`) already constructs the full QEMU command line. It reads these environment variables:

| Variable | Purpose |
|----------|---------|
| `NIX_DISK_IMAGE` | Disk image path |
| `QEMU_OPTS` | Extra QEMU flags appended to the invocation |
| `QEMU_NET_OPTS` | Network options |
| `$@` | Additional positional arguments |

The correct pattern is to set environment variables and execute the runner:

```sh
export NIX_DISK_IMAGE="/path/to/disk.qcow2"
export QEMU_OPTS="${QEMU_OPTS:+${QEMU_OPTS} }-device isa-debug-exit,iobase=0xf4,iosize=0x04"
exec "${VM_PATH}"
```

The runner handles everything else. No dynamic command construction needed.

## Build-Time Constants vs Runtime Overrides

Build-time constants (like `isa-debug-exit` flags) should be baked into `QEMU_OPTS` in the Nix layer, not passed as separate `runtimeEnv` variables. Only values that need runtime override belong in `runtimeEnv`.

```nix
# In Nix — bake constants into EXTRA_QEMU_OPTS
EXTRA_QEMU_OPTS = concatStringsSep " " ([
	"-device isa-debug-exit,iobase=0xf4,iosize=0x04"
] ++ extraQemuOptions);
```

```sh
# In runner.sh — append to QEMU_OPTS
export QEMU_OPTS="${QEMU_OPTS:+${QEMU_OPTS} }${EXTRA_QEMU_OPTS}"
```

## How to Address

- Document the NixOS VM runner's environment variable interface in `.opencode/context/`
- Add a rule: "Never construct QEMU arguments in shell scripts — use environment variables that the NixOS VM runner reads"

## Related Quests

- [posix-shell-compliance](../posix-shell-compliance/quest.md) — POSIX sh compliance (no Bash arrays)
- [disk-strategy-portability](../disk-strategy-portability/quest.md) — Disk strategy portability
- [nix-repl-vm-testing](../nix-repl-vm-testing/quest.md) — VM testing from nix repl