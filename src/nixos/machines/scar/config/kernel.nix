{ lib, pkgs, ... }:

# Kernel management of SCAR

{
	# boot.kernelPackages = pkgs.linuxPackages_xanmod;
	boot.kernelPackages = pkgs.linuxPackages;

	boot.kernelParams = [];

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
