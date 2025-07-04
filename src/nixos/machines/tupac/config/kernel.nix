{ config, lib, pkgs, ... }:

# Kernel management of TUPAC

let
	inherit (lib) mkForce mkIf;
in {
	boot.kernelPackages = pkgs.linuxPackages_xanmod;

	# boot.kernelParams = [
	# 	# SECURITY(Krey): Used to manage CPU Vulnerabilities
	# 	"tsx=auto" # Let Linux Developers determine if the mitigation is needed
	# 	"tsx_async_abort=full,nosmt" # Enforce Full Mitigation if the management is needed
	# 	"mds=off" # Paranoid enforcement, shouldn't be needed..
	# ];

	# SECURITY(Krey): Has vulnerable CPU so this has to be managed
	security.allowSimultaneousMultithreading = mkForce false; # Disable Simultaneous Multi-Threading as on this system it exposes unwanted attack vectors and CPU vulnerabilities

	# SECURITY(Krey): NiXium-important packages require this atm
	# * vscodium - Pending management on MORPH (remote codium server)
	security.unprivilegedUsernsClone = true;

	# The driver causes conflicts with ACPI, so it's disabled (https://forums.gentoo.org/viewtopic-t-1068292-start-0.html)
	boot.blacklistedKernelModules = [ "lpc_ich" ];

	# Kernel Modules
	boot.kernelModules = [
		"kvm-intel" # Use KVM
		(mkIf config.networking.wireguard.enable "wireguard")
	];
}
