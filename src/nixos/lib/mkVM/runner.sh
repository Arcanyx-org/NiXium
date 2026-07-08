# NiXium VM Runner — 3-mode disk strategy, GPU passthrough, exit code propagation
#
# This script is included via `builtins.readFile` in src/nixos/lib/vm/default.nix.
# Do NOT add Bash-specific features — this must be strict POSIX sh (ksh compatible).
#
# FIXME(Krey): Replace echo; exit with helper function for error handling

# shellcheck disable=SC2034 # Injected via runtimeEnv
{
	: "$VM_NAME"
	: "$MODULE_PATH"
	: "$GUEST_SYSTEM"
	: "$VM_PATH"
	: "$GPU_PASSTHROUGH_DEFAULT"
	: "$TIMEOUT"
	: "$EXIT_MODE"
	: "$EXTRA_QEMU_OPTS"
}

# -------------------------------------------------------------------------
# Architecture mismatch warning
# -------------------------------------------------------------------------
HOST_ARCH="$(uname -m)"
GUEST_ARCH="${GUEST_SYSTEM%%-*}"

# Normalise uname output to Nix system arch naming
case "$HOST_ARCH" in
	x86_64|amd64) HOST_ARCH="x86_64" ;;
	aarch64|arm64) HOST_ARCH="aarch64" ;;
esac

if [ "$GUEST_ARCH" != "$HOST_ARCH" ]; then
	echo "WARNING: This VM is built for $GUEST_SYSTEM but running on $HOST_ARCH host." >&2
	echo "  Cross-architecture emulation will be slow. Some features may not work." >&2
fi

# -------------------------------------------------------------------------
# Disk strategy (3 modes)
# -------------------------------------------------------------------------
# Mode 1: Dev — FLAKE_ROOT is a valid directory, persist disk next to module
# Mode 2: User override — NIX_DISK_IMAGE set explicitly
# Mode 3: Ephemeral — ${TMPDIR:-/var/tmp} with QEMU -snapshot
if [ -d "${FLAKE_ROOT:-}" ]; then
	export NIX_DISK_IMAGE="${FLAKE_ROOT}/${MODULE_PATH}/${VM_NAME}.qcow2"
elif [ -n "${NIX_DISK_IMAGE:-}" ]; then
	: # Use NIX_DISK_IMAGE as-is
else
	# Use TMPDIR if set (macOS, custom Linux), fall back to /var/tmp (FHS)
	# Warn if TMPDIR=/tmp since it may be tmpfs (RAM-backed)
	if [ "${TMPDIR:-/var/tmp}" = "/tmp" ]; then
		echo "WARNING: TMPDIR is /tmp, which may be tmpfs (RAM-backed)." >&2
		echo "  Large VM disk overlays may cause OOM. Consider setting TMPDIR" >&2
		echo "  to a disk-backed directory." >&2
	fi
	export NIX_DISK_IMAGE="${TMPDIR:-/var/tmp}/nixium-vm-${VM_NAME}.qcow2"
	export QEMU_OPTS="${QEMU_OPTS:+${QEMU_OPTS} }-snapshot"
fi

# -------------------------------------------------------------------------
# GPU passthrough
# -------------------------------------------------------------------------
# Priority: GPU_PASSTHROUGH env var > GPU_PASSTHROUGH_DEFAULT build param > null
# GPU_PASSTHROUGH_DEFAULT is used instead of GPU_PASSTHROUGH in runtimeEnv
# because runtimeEnv uses hard assignment (VAR='value') which overwrites any
# user-set environment variable. The _DEFAULT suffix preserves the override chain.
GPU_PT="${GPU_PASSTHROUGH:-${GPU_PASSTHROUGH_DEFAULT}}"

if [ -n "$GPU_PT" ]; then
	if [ "$GPU_PT" = "auto" ]; then
		# Auto-detect: check IOMMU, enumerate GPUs via lspci, pick the first one
		if [ ! -d /sys/kernel/iommu_groups ] || [ -z "$(ls /sys/kernel/iommu_groups 2>/dev/null)" ]; then
			echo "ERROR: IOMMU is not enabled on this host." >&2
			echo "  GPU passthrough requires IOMMU support." >&2
			echo "  Add 'intel_iommu=on iommu=pt' (Intel) or 'amd_iommu=on iommu=pt' (AMD)" >&2
			echo "  to your host kernel parameters and reboot." >&2
			exit 1
		fi

		echo "Detecting GPUs for passthrough..." >&2
		# lspci outputs short form (01:00.0); QEMU needs full form (0000:01:00.0)
		GPU_LIST="$(lspci -D | grep -iE "VGA|3D|Display" || true)"

		if [ -z "$GPU_LIST" ]; then
			echo "ERROR: No GPU found for auto passthrough." >&2
			echo "  Specify a PCI address manually: GPU_PASSTHROUGH=0000:01:00.0" >&2
			exit 1
		fi

		echo "Found GPUs:" >&2
		echo "$GPU_LIST" >&2
		# Select first GPU; take full PCI address from lspci -D output
		GPU_ADDR="$(echo "$GPU_LIST" | head -1 | cut -d" " -f1)"
		echo "Using GPU: $GPU_ADDR" >&2
		echo "  To use a different GPU, set: GPU_PASSTHROUGH=<pci-address>" >&2
	else
		# Explicit PCI address: normalise short form to full form if needed
		GPU_ADDR="$GPU_PT"
		case "$GPU_ADDR" in
			[0-9a-fA-F][0-9a-fA-F]:[0-9a-fA-F][0-9a-fA-F].[0-9a-fA-F])
				GPU_ADDR="0000:$GPU_ADDR"
				;;
		esac
	fi

	export QEMU_OPTS="${QEMU_OPTS:+${QEMU_OPTS} }-device vfio-pci,host=$GPU_ADDR"
else
	# No passthrough — print a one-time tip so users know the feature exists
	echo "Tip: Set GPU_PASSTHROUGH=auto to enable GPU passthrough (requires IOMMU)." >&2
fi

# -------------------------------------------------------------------------
# Assemble QEMU options and run
# -------------------------------------------------------------------------
# Build-time constants (isa-debug-exit, extraQemuOptions) are already baked
# into EXTRA_QEMU_OPTS by the Nix layer. Runtime additions (GPU flags) are
# appended to QEMU_OPTS above. The NixOS VM runner reads QEMU_OPTS and $@
# to construct the full QEMU command line — we do NOT construct it ourselves.
export QEMU_OPTS="${QEMU_OPTS:+${QEMU_OPTS} }${EXTRA_QEMU_OPTS}"

# -------------------------------------------------------------------------
# Exit code propagation
# -------------------------------------------------------------------------
if [ "$EXIT_MODE" = "propagate" ]; then
	# Run QEMU; capture its exit code for decoding
	# QEMU exits with (guest_code << 1) | 1 when isa-debug-exit fires
	set +e
	if [ -n "$TIMEOUT" ]; then
		timeout "$TIMEOUT" "${VM_PATH}" "$@"
	else
		"${VM_PATH}" "$@"
	fi
	QEMU_EXIT=$?
	set -e

	# Normal QEMU exit (0 = clean shutdown without isa-debug-exit)
	if [ "$QEMU_EXIT" -eq 0 ]; then
		exit 0
	fi

	# Timeout exit (coreutils timeout exits with 124)
	if [ -n "$TIMEOUT" ] && [ "$QEMU_EXIT" -eq 124 ]; then
		echo "ERROR: VM timed out after ${TIMEOUT} seconds." >&2
		exit 124
	fi

	# Decode isa-debug-exit encoding: HOST_EXIT = (QEMU_EXIT - 1) >> 1
	# Only valid when low bit is set (isa-debug-exit fired)
	if [ $(( QEMU_EXIT & 1 )) -eq 1 ]; then
		HOST_EXIT=$(( (QEMU_EXIT - 1) >> 1 ))
		exit "$HOST_EXIT"
	fi

	# Unexpected QEMU exit code — propagate as-is
	exit "$QEMU_EXIT"
else
	# exitMode = "poweroff" or "shell" — just run the VM, no exit code decoding
	if [ -n "$TIMEOUT" ]; then
		exec timeout "$TIMEOUT" "${VM_PATH}" "$@"
	else
		exec "${VM_PATH}" "$@"
	fi
fi