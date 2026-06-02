{ lib, pkgs, ... }:

# Kernel Management of MRACEK

let
	inherit (lib) mkForce;
in {
	# FIXME-SECURITY(Krey): Make a Libre Kernel with Hardened patches
	# FIXME(Krey): error: linux_libre has been removed due to lack of maintenance
		# boot.kernelPackages = mkForce pkgs.linuxPackages-libre; # Use Linux-Libre

	boot.kernelParams = [
		# FIXME-SECURITY(Krey): Used to manage CPU Vulnerabilities, migrate to global module and apply by default to all x86_64 devices
			"tsx=auto" # Let Linux Developers determine if the mitigation is needed
			"tsx_async_abort=full,nosmt" # Enforce Full Mitigation if the management is needed
			"mds=off" # Paranoid enforcement, shouldn't be needed..
	];

	# FIXME(Krey): This should be in global module
		# The driver causes conflicts with ACPI, so it's disabled (https://forums.gentoo.org/viewtopic-t-1068292-start-0.html)
		boot.blacklistedKernelModules = [ "lpc_ich" ];
}
