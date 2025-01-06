{ pkgs, lib, ... }:

# Kernel Management of LENGO

let
	inherit (lib) mkForce;
in {
	# FIXME(Krey): Move on harneded kernel, tbd how to manage
	boot.kernelPackages = mkForce pkgs.linuxPackages;

	boot.kernelParams = [
		# SECURITY(Krey): Used to manage CPU Vulnerabilities
		"tsx=auto" # Let Linux Developers determine if the mitigation is needed
		"tsx_async_abort=full,nosmt" # Enforce Full Mitigation if the management is needed
		"mds=off" # Paranoid enforcement, shouldn't be needed..
	];

	boot.kernelModules = [
		"kvm-amd" # Use KVM
		"usb-storage" # Use USB drives on hardened kernel
	];

	boot.blacklistedKernelModules = [ ];

	# SECURITY(Krey): Has vulnerable CPU so this has to be managed
	security.allowSimultaneousMultithreading = mkForce false; # Disable Simultaneous Multi-Threading as on this system it exposes unwanted attack vectors and CPU vulnerabilities

	# SECURITY(Krey): Handled externally via coreboot management
	hardware.cpu.intel.updateMicrocode = mkForce false; # Whether to update the intel CPU microcode on system bootup
}
