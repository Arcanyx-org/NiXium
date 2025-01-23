{ lib, config, pkgs, ... }:

# Security management of FLEXY

# SECURITY(Krey): For some reason it's not pulling the latest microcode during testing, investigate this more once it has NiXium deployed on it
#   * CPU microcode is the latest known available version:  NO  (latest version is 0x860010c dated 2023/10/07 according to builtin firmwares DB v296+i20240514+988c)

let
	inherit (lib) mkMerge mkForce mkDefault mkIf;
in {
	config = mkMerge [
		{
			security.allowSimultaneousMultithreading = mkForce false; # Disable Simultaneous Multi-Threading as on this system it exposes unwanted attack vectors

			# NOTE(Krey): Breaks USB
			security.lockKernelModules = false;

			# NOTE(Krey): Breaks hibernation
			security.protectKernelImage = false;

			# SECURITY(Krey): Some packages run in electron (vscodium) which requires this, in process of managing it
			security.unprivilegedUsernsClone = true;

			# Kernel
				boot.kernelPackages = mkForce pkgs.linuxPackages_hardened; # Always use the Hardened Kernel

				boot.kernelParams = mkForce [
					"tsx=auto" # Let Linux Developers determine if the mitigation is needed
					"tsx_async_abort=full,nosmt" # Enforce Full Mitigation if the management is needed
					"mds=off" # Paranoid enforcement, shouldn't be needed..
				];

			# Necessary Evil to keep the CPU microcode up-to-date, such is all i686 and amd64 architecture systems
			hardware.enableRedistributableFirmware = true;
			hardware.cpu.amd.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;
		}

		# # Enforce to use the Tor Proxy
		# (mkIf config.services.tor.enable {
		# 	networking.proxy.default = mkDefault "socks5://127.0.0.1:9050";
		# 	networking.proxy.noProxy = mkDefault "127.0.0.1,localhost";
		# })
	];
}
