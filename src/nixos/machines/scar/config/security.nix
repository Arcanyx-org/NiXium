{ lib, ... }:

# Security management of SCAR

let
	inherit (lib) mkForce;
in {
	# protectKernelImage blocks the kernel image memory from being snapshotted for hibernation — disable to keep hibernation functional on this laptop.
	security.protectKernelImage = mkForce false;

	# Lock kernel modules after boot — prevents loading unverified modules at runtime. All drivers needed for normal operation + hibernation (storage, ACPI, PM, i915, nvidia) are loaded at boot and persist across suspend/resume. Hotplug modules (e.g. USB gadgets) require a reboot, but this laptop's hardware is entirely built-in.
	security.lockKernelModules = mkForce true;

	# Panic (halt/reboot) on any kernel oops/BUG() instead of continuing in undefined/corrupt state. Standard hardening — if you need to capture oops output (pentesting/debugging), override to 0.
	boot.kernel.sysctl."kernel.panic_on_oops" = 1;

	security.allowSimultaneousMultithreading = mkForce false; # Disable SMT as it exposes CPU vulnerabilities
}
