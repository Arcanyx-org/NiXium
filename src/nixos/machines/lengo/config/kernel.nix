{ config, pkgs, lib, ... }:

# Kernel Management of LENGO

let
	inherit (lib) mkForce;
in {
	# FIXME(Krey): Move on harneded kernel, tbd how to manage
	# FIXME(Krey): Add this patch https://lkml.org/lkml/2024/12/17/1611
	# NOTE(Krey): Causes GDM to fail to load
		# boot.kernelPackages = mkForce pkgs.linuxPackages_6_12;
	boot.kernelPackages = mkForce pkgs.linuxPackages;

	boot.kernelParams = [
		# SECURITY(Krey): Used to manage CPU Vulnerabilities
		"tsx=auto" # Let Linux Developers determine if the mitigation is needed
		"tsx_async_abort=full,nosmt" # Enforce Full Mitigation if the management is needed
		"mds=off" # Paranoid enforcement, shouldn't be needed..
	];

	# Zenpower is said to be better for modern AMD things
	boot.extraModulePackages = with config.boot.kernelPackages; [ zenpower ];

	boot.kernelModules = [
		"kvm-amd" # Use KVM
		"usb-storage" # Use USB drives on hardened kernel
		"zenpower"
	];

	boot.blacklistedKernelModules = [
		# FIXME-QA(Krey): Junior Nix Dev Figured this out without knowing why and i am blindly following his config.. figure out if it's actually a good idea to prefer zenpower over k10temp
		"k10temp"
		# The driver causes conflicts with ACPI, so it's disabled (https://forums.gentoo.org/viewtopic-t-1068292-start-0.html)
		"lpc_ich"
	];

	# SECURITY(Krey): Has vulnerable CPU so this has to be managed
	security.allowSimultaneousMultithreading = mkForce false; # Disable Simultaneous Multi-Threading as on this system it exposes unwanted attack vectors and CPU vulnerabilities

	# SECURITY(Krey): Handled externally via coreboot management
	hardware.cpu.intel.updateMicrocode = mkForce false; # Whether to update the intel CPU microcode on system bootup
}
