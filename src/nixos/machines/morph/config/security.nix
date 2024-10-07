{ lib, config, pkgs, ... }:

# Security management of MORPH

let
	inherit (lib) mkMerge mkForce;
in {
	config = mkMerge [
		{
			# NOTE(Krey): MORPH is a Gaming Server that might eventually need either better CPU or this disabled as the lack of CPU processing might result in a lag for some games
			security.allowSimultaneousMultithreading = mkForce false;

			# Kernel
				# NOTE(Krey): Might require patches to gain more performance out of it's hardware eventually
				# boot.kernelPackages = mkForce pkgs.linuxPackages_hardened; # Always use the Hardened Kernel

				boot.kernelParams = mkForce [
					"tsx=auto" # Let Linux Developers determine if the mitigation is needed
					"tsx_async_abort=full,nosmt" # Enforce Full Mitigation if the management is needed
					"mds=off" # Paranoid enforcement, shouldn't be needed..
				];

			# SECURITY(Krey): Currently a necessary malware to keep the CPU functional.. Such is the curse of i686/amd64 systems
			hardware.cpu.amd.updateMicrocode = mkForce true;

			# NOTE(Krey): System designed to not need this, but it's required for the RX 570 to initialize for some fucking reason
			hardware.enableRedistributableFirmware = mkForce true;
		}
	];
}
