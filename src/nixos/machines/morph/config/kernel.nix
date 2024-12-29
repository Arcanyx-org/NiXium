{ pkgs, config, lib, ... }:

# Kernel Management of MORPH

let
	inherit (lib) mkIf mkForce;
in {
	# NOTE(Krey): Morph is projected to be used as a gaming server where the hardened kernel might impact it's performance too much
	# FIXME-SECURITY(Krey): Hardened kernel causes lot of issues, pending custom kernel
	boot.kernelPackages = mkForce pkgs.linuxPackages;

	# Kernel Modules
	boot.kernelModules = [
		"kvm-intel" # Use KVM
		(mkIf config.networking.wireguard.enable "wireguard")
	];

	boot.extraModulePackages = [ ];

	# Experiment(Krey)
	security.lockKernelModules = false; # Prefer to Lock Kernel Modules by default
	security.protectKernelImage = false; # Prefer to Protect Kernel Image by default
}
