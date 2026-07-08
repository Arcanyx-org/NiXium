<!-- SUMMARY: All shell scripts in NiXium must be strict POSIX sh (ksh compatible). No Bash arrays, [[ ]], or process substitution. LOAD WHEN: Writing shell scripts in Nix, reviewing shell script compliance. SKIP WHEN: Not working on shell scripts. -->

# Quest: POSIX `sh` Compliance in `writeShellApplication`

## Metadata

| Field | Value |
|-------|-------|
| **Status** | Decided |
| **Priority** | High |
| **Created** | 2026-04-13 |
| **Updated** | 2026-04-13 |
| **Assigned** | TBD |

## Problem

Agents working on NiXium lack context that all shell scripts must be strict POSIX sh (ksh compatible), despite `writeShellApplication` executing via bash. Without this context, agents use Bashisms like arrays, `[[ ]]` tests, and process substitution.

## The Anti-Pattern: Bashisms

Because `writeShellApplication` defaults to `bash`, it is easy to assume Bash-specific features are acceptable:

```sh
# WRONG ❌ (Bash array)
declare -a qemu_args=( "-m" "2048" )
qemu_args+=( "-drive" "file=$DISK" )
qemu-system-x86_64 "${qemu_args[@]}"
```

```sh
# WRONG ❌ (Bash conditional)
if [[ "$VAR" == "auto" ]]; then
```

## The Correct Pattern: Enforce POSIX `sh`

Add `"posix"` to `bashOptions` as a signal of intent. Real compliance comes from writing POSIX sh code and running `shellcheck` separately.

```nix
pkgs.writeShellApplication {
	name = "my-script";
	bashOptions = [ "errexit" "nounset" "pipefail" "posix" ];
	# ...
}
```

## Environment Variables Over Command Construction

The most common reason agents reach for Bash arrays is dynamic command construction. In NiXium's VM library, this is unnecessary because the NixOS VM runner (`run-nixos-vm`) already constructs the full QEMU command line. It reads environment variables:

| Variable | Purpose |
|----------|---------|
| `NIX_DISK_IMAGE` | Disk image path |
| `QEMU_OPTS` | Extra QEMU flags appended to invocation |
| `QEMU_NET_OPTS` | Network options |
| `$@` | Additional positional arguments |

The correct pattern is to **set environment variables and execute the runner**, not to construct QEMU arguments:

```sh
export NIX_DISK_IMAGE="/path/to/disk.qcow2"
export QEMU_OPTS="${QEMU_OPTS:+${QEMU_OPTS} }-device isa-debug-exit,iobase=0xf4,iosize=0x04"
exec "${VM_PATH}"
```

This eliminates the need for arrays, `set --`, `${var:+"$var"}`, or IFS manipulation entirely.

## If Dynamic Command Construction Is Truly Needed

For cases where environment variables are insufficient and dynamic arguments are required:

### Approach 1: Positional Parameters (`set --`)

```sh
set -- -m 2048 -smp 2
if [ "$CONDITION" = "true" ]; then
	set -- "$@" -drive "file=$DISK_PATH"
fi
exec qemu-system-x86_64 "$@"
```

### Approach 2: Conditional Variables with `${var:+"$var"}`

```sh
DISK_FLAG=""
DISK_ARG=""
if [ -n "$FLAKE_ROOT" ]; then
	DISK_FLAG="-drive"
	DISK_ARG="file=$FLAKE_ROOT/disk.qcow2,format=qcow2"
fi
exec qemu-system-x86_64 ${DISK_FLAG:+"$DISK_FLAG"} ${DISK_ARG:+"$DISK_ARG"}
```

**Warning:** Approach 2 is only safe if the variable does not contain internal spaces that shouldn't be split. For paths with spaces, Approach 1 is mandatory.

## How to Address

- Add POSIX sh requirement to `.opencode/context/` coding standards
- Add a `shellcheck` pre-commit hook or CI check for standalone `.sh` files
- Consider a custom `shellcheck` config that recognizes `runtimeEnv`-injected variables

## Related Quests

- [add-shell-standards-to-nx-standard](../add-shell-standards-to-nx-standard/quest.md) — Comprehensive shell script standards
- [write-shell-app-ksh-shfmt](../write-shell-app-ksh-shfmt/quest.md) — ksh default, shfmt optional
- [env-vars-over-command-construction](../env-vars-over-command-construction/quest.md) — Environment variables over command construction