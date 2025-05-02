{ pkgs, config, lib, ... }:

# Kernel Management of SINNENFREUDE

let
	inherit (lib) mkIf;
in {
	# boot.kernelPackages = pkgs.linuxPackages_hardened; # Use hardened kernel
	boot.kernelPackages = pkgs.linuxPackages;

	# SECURITY(Krey): NiXium-important packages require this atm
	# * vscodium - Pending management on MORPH
	security.unprivilegedUsernsClone = true;

	# Kernel Modules
	boot.kernelModules = [
		"kvm-intel" # Use KVM
		(mkIf config.networking.wireguard.enable "wireguard")
	];
}
