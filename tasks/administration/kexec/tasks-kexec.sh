###! NiXium Kexec Task — Architecture, Constraints & Deferred Implementation
###!
###! ## Overview
###!
###! This task is intended to perform the equivalent of `nixos-rebuild boot && reboot`
###! using the `kexec` syscall, which loads and executes a new kernel without going
###! through firmware (BIOS/UEFI POST, bootloader, GRUB menu). The primary
###! motivation is to speed up development iteration by preserving LUKS-unlocked
###! state across kernel switches — avoiding the ~30-60s firmware dance and
###! repeated LUKS password entry on every config change.
###!
###! ## Status: NOT IMPLEMENTED (Deferred)
###!
###! This task exits with a "not implemented" message. The implementation was
###! attempted but hit fundamental architectural blockers that cannot be resolved
###! until the agenix fork rewrite (Arcanyx, in progress) is complete and a
###! coherent authentication/deployment strategy is in place.
###!
###! See: AGENTS.md §"Kexec Task" for operational context.
###!
###! ## Kernel-Level Mechanism
###!
###! kexec(2) syscall flow:
###!   1. `kexec -l <kernel> --initrd=<initrd> --command-line="<params>"`
###!      → calls kexec_load() → copies the new kernel + initrd + cmdline into
###!        reserved memory via KEXEC_SEGMENT_MAX segments
###!      → does NOT yet execute anything; just stages the payload
###!   2. `kexec -e` → calls reboot(LINUX_REBOOT_CMD_KEXEC)
###!      → kernel calls machine_shutdown() → device_shutdown() → cpuidle_pause()
###!      → machine_kexec() → turns off interrupts, stops secondary CPUs
###!      → copies the staged segments to their final locations
###!      → installs the new kernel's entry point into the reset vector
###!      → issues a CPU reset (or equivalent architecture-specific jump)
###!      → new kernel begins execution from its startup_32/startup_64 entry
###!
###! Critical consequence: **the old kernel's .data, .bss, heap, slab caches,
###! and all dynamic allocations are obliterated.** The new kernel starts with
###! zero knowledge of the previous kernel's internal state.
###!
###! ## Why dm-crypt Mappings Are Lost (and Cannot Be Preserved)
###!
###! dm-crypt device mapper targets store their encryption keys in the kernel's
###! slab allocator — specifically in the `struct crypt_config` allocated via
###! `kzalloc()` in `dm-crypt.c:crypt_ctr()`. This structure contains:
###!
###!   - `cc_key` — the raw encryption key (AES-XTS tweak + cipher keys)
###!   - `cc_key_size` — key length in bytes
###!   - `cc_iv_gen_ops` — IV generation function pointers
###!   - `cc_cipher` — crypto API cipher handle (itself a kernel object)
###!   - `cc_dm` — pointer to the mapped device
###!
###! These are in dynamically allocated kernel memory (slab). kexec replaces ALL
###! kernel memory — the `.text`, `.data`, `.bss` segments of the old kernel are
###! unmapped and overwritten by the new kernel's segments. There is:
###!
###!   - **No kexec handover mechanism for device mapper** — unlike `simplefb`
###!     (which preserves the framebuffer via a memory region), dm has no
###!     "preserve and re-attach" protocol
###!   - **No ioctl to read back the key from userspace** — `CRYPT_GET_KEY`
###!     does not exist; the key is intentionally inaccessible from userspace
###!     (see `crypt_ctr()` — the key is copied into `cc_key` via `memcpy`
###!     from a transient userspace buffer, then the userspace buffer is
###!     `memset()` to zero)
###!   - **No way to enumerate active dm targets from outside the kernel**
###!     — `/sys/block/dm-*/` metadata does not contain key material
###!   - **Keyring-backed keys are also lost** — `kernel_keyring` is in slab
###!     memory like everything else
###!
###! Attempted workarounds (all rejected):
###!
###!   **Keyfile on /boot** — rejected as an obvious security threat; the
###!   unencrypted EFI partition is trivially readable by anyone with physical
###!   access, and LUKS keyfiles do not benefit from the KDF hardening that
###!   passphrase entry provides
###!
###!   **Pass password via kernel cmdline** — `rd.luks.*` only accepts keyfile
###!   paths, not inline secrets; also leaks into `/proc/cmdline` and dmesg
###!
###!   **Inject password via initrd overlay** — requires knowing the password
###!   at kexec time; the password is not stored in decrypted form anywhere
###!   on the running system (by design)
###!
###!   **Preserve dm-crypt memory regions across kexec** — the key is in a
###!   slab-allocated structure at a non-deterministic physical address; even
###!   if we could locate it, the new kernel cannot attach to an existing
###!   `struct crypt_config` because the crypto API cipher handles and memory
###!   management structures are kernel-version-specific
###!
###! ## GPU/Console Initialization Failure After kexec
###!
###! On UEFI systems (tupac), the display console is provided by the EFI GOP
###! (Graphics Output Protocol) framebuffer. During a cold boot:
###!
###!   1. UEFI firmware POST initializes the GPU (i915) and sets up a linear
###!      framebuffer via GOP
###!   2. The kernel boots, the `efifb` driver claims the GOP framebuffer
###!      (using the address from the EFI Boot Services table)
###!   3. i915 loads, takes over from efifb, sets up KMS (Kernel Mode Setting)
###!   4. plymouth uses i915 DRM to display the graphical LUKS prompt
###!
###! After kexec:
###!
###!   1. kexec calls `machine_shutdown()` → `device_shutdown()` — this calls
###!      driver shutdown callbacks. i915's shutdown callback disables the
###!      display engine, puts the GPU in D3hot state
###!   2. The old kernel is replaced; the new kernel starts
###!   3. New kernel's i915 tries to re-initialize the GPU via MMIO register
###!      writes, but the hardware is in an inconsistent state because:
###!      - GPU firmware (GuC/HuC) was loaded by the old kernel (lost)
###!      - Display PLLs and DPLL configuration were set by the old kernel
###!      - The GTT (Graphics Translation Table) was set up by the old kernel
###!      - PCI config space may have stale values from the old kernel's
###!        shutdown sequence
###!   4. i915 init fails → no KMS → no modesetting → no console
###!   5. efifb is not re-probed because `ExitBootServices()` was already
###!      called during the original boot, and the GOP protocol pointer is
###!      invalidated
###!   6. Result: black screen, system otherwise functional (fans spin, SSH
###!      works if networking is up, but no display output)
###!
###! Partial mitigations tested:
###!
###!   `nomodeset` — disables KMS driver loading, falls back to efifb/vesafb.
###!   But efifb needs the framebuffer address from EFI, which requires the
###!   old kernel to have preserved it in the FDT or ACPI tables. After kexec,
###!   this information is not reliably available. Result: still black.
###!
###!   `console=tty0` + strip `splash` — forces kernel messages to the VT
###!   console, but the VT console itself is backed by the same broken
###!   framebuffer. If fbcon can't find a valid framebuffer, no text output.
###!
###! ## nixpkgs kexecTree Approach (Reference Implementation)
###!
###! nixpkgs provides `config.system.build.kexecTree` in
###! `nixos/modules/installer/netboot/netboot.nix`. It builds a self-contained
###! kexec payload:
###!
###!   - `bzImage` — the system kernel (`config.system.build.kernel`)
###!   - `initrd.gz` — a **netboot initrd** containing a squashfs of the
###!     entire Nix store (via `make-squashfs.nix`), NOT the system's real
###!     initrd
###!   - `kexec-boot` — a script that runs:
###!       kexec --load bzImage \\
###!         --initrd=initrd.gz \\
###!         --command-line "init=\${toplevel}/init \${boot.kernelParams}"
###!       kexec -e
###!
###! This works reliably because the netboot initrd:
###!   - Mounts tmpfs as root (no LUKS, no real filesystems needed)
###!   - Uses squashfs overlay for /nix/store (self-contained, no disk access)
###!   - Does not touch any encrypted partitions → no password prompt
###!   - No hardware dependencies beyond basic PCI/block/fs support
###!
###! But it does NOT satisfy NiXium's requirements because:
###!   - It boots into an ephemeral environment (tmpfs root → all state lost)
###!   - /nix/store is read-only (squashfs) — cannot `nixos-rebuild` inside it
###!   - Does not preserve LUKS, running services, or persistent state
###!   - Useful only for rescue/deployment, not for development live-patching
###!
###! ## The Correct Solution (Blocked)
###!
###! The only way to achieve password-less kexec with the real system initrd
###! is **auto-unlocking LUKS during initrd without user interaction**. This
###! requires a trust anchor that survives kexec (i.e., lives outside kernel
###! memory). Options ranked by desirability:
###!
###!   1. **TPM2 `systemd-cryptenroll`** — the TPM2 chip is independent
###!      hardware; its PCR registers and sealed keys survive kexec. The
###!      initrd's `systemd-cryptsetup` can:
###!        systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p3
###!      This stores the LUKS key in the TPM, sealed against PCR 0+7
###!      (BIOS/UEFI firmware + SecureBoot state). After kexec, the initrd
###!      unseals the key from TPM — no password, no keyfile. Requires:
###!        - TPM2 chip (tupac likely has one — Intel PTT or dTPM)
###!        - `boot.initrd.luks.devices."nix-store".tpm2.enable = true`
###!        - One-time enrollment command
###!      — This is the recommended approach once the auth rewrite settles.
###!
###!   2. **FIDO2 (Nitrokey/YubiKey)** — similar to TPM2 but uses a USB
###!      hardware token. The token survives kexec (USB re-enumerated).
###!      `systemd-cryptenroll --fido2-device=auto /dev/nvme0n1p3`. Requires
###!      the token to be plugged in during boot. Works for both cold boot
###!      and kexec. — Good fallback if no TPM2.
###!
###!   3. **Age secret in initrd (agneix fork rewrite)** — once the agenix
###!      rewrite is complete (Arcanyx, in progress), the age identity key
###!      (SSH host key) should be accessible before LUKS unlock by storing
###!      a copy on the unencrypted boot partition. Then the initrd can
###!      decrypt the LUKS password secret via agenix, avoiding both a
###!      plaintext keyfile and user interaction. This is the NiXium-native
###!      solution but is BLOCKED until the agenix rewrite ships.
###!
###! ## Architecture Decisions for the Future Implementation
###!
###! When this is eventually implemented, it should:
###!
###!   1. Build the system via `nixos-rebuild build` (already works)
###!   2. Extract `result/kernel`, `result/initrd`, `result/kernel-params`
###!   3. Construct kernel cmdline by filtering `splash` and adding
###!      `console=tty0 loglevel=7` (to mitigate GPU console issues)
###!   4. Call `kexec -l` on the target system (locally or via SSH)
###!   5. Confirm with user before `kexec -e`
###!   6. Execute `kexec -e`
###!
###! The password-less LUKS unlock must be handled OUTSIDE this task —
###! either via TPM2 enrollment or the agenix rewrite — because the task
###! cannot and should not manage LUKS credentials.
###!
###! ## See Also
###!
###! - AGENTS.md §"Kexec Task" (operational documentation)
###! - src/nixos/modules/apps/kexec/apps-kexec.nix (auto-adds kexec-tools)
###! - nixpkgs: nixos/modules/installer/netboot/netboot.nix (kexecTree ref)
###! - Linux: kernel/kexec.c, drivers/md/dm-crypt.c
###! - systemd: src/cryptsetup/cryptsetup-tpm2.c (TPM2 enrollment)
###! - Arcanyx: agenix fork (vendor/agenix/)

# shellcheck shell=sh # POSIX

echo "The kexec task is not yet implemented — see the spec comments above for details."
exit 0