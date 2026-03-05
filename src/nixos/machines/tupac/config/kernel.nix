{ lib, pkgs, ... }:

# Kernel management of TUPAC

let
	inherit (lib) mkForce;
in {
	# boot.kernelPackages = pkgs.linuxPackages_xanmod;
	boot.kernelPackages = pkgs.linuxPackages;

	boot.kernelParams = [
		# SECURITY(Krey): Used to manage CPU Vulnerabilities
		# "tsx=auto" # Let Linux Developers determine if the mitigation is needed
		# "tsx_async_abort=full,nosmt" # Enforce Full Mitigation if the management is needed
		# "mds=off" # Paranoid enforcement, shouldn't be needed..

		# FIXME(Krey): Tulpar T5 V23.2 BIOS bug - VBT table reports invalid DisplayPort info for Port B
		# This causes WARNING in intel_bios.c:2698 and atomic update failures
		# i915.enable_dc=0 disables display power management to work around the VBT bug
		# See: https://github.com/torvalds/linux/blob/master/drivers/gpu/drm/i915/display/intel_bios.c
		"i915.enable_dc=0"

		# FIXME(Krey): Intel AX201 Bluetooth firmware incompatibility with kernel MGMT interface
		# Causes "Bad flag given (0x1) vs supported (0x0)" error
		# btintel.force_bdaddr=1 forces using the BDADDR from firmware
		# Related: https://bugzilla.kernel.org/show_bug.cgi?id=217023
		"btintel.force_bdaddr=1"
	];

	# SECURITY(Krey): Has vulnerable CPU so this has to be managed
	security.allowSimultaneousMultithreading = mkForce true; # Disable SMT as it exposes CPU vulnerabilities

	# SECURITY(Krey): NiXium-important packages require this atm
	# * vscodium - Pending management on MORPH (remote codium server)
	security.unprivilegedUsernsClone = true;

	# The driver causes conflicts with ACPI, so it's disabled (https://forums.gentoo.org/viewtopic-t-1068292-start-0.html)
	boot.blacklistedKernelModules = [ "lpc_ich" ];

	# Kernel Modules
	boot.kernelModules = [
		"kvm-intel" # Use KVM
		# FIXME(Krey): Fix for 25.11
			# (mkIf config.networking.wireguard.enable "wireguard")
	];
}
