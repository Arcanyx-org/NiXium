{ lib, config, pkgs, ... }:

#! # Security management of MRACEK
#! System has a vulnerable CPU (...) that needs management to be suitable for high-security mission-critical environment
#!
#! ## Management of TSX Asynchronous Abort
#! TAA (CVE-2019-11135) is a hardware vulnerability that allows unprivileged speculative access to data which is available in various CPU internal buffers by using asynchronous aborts within an Intel TSX transactional region, refer to https://docs.kernel.org/admin-guide/hw-vuln/tsx_async_abort.html for more info.
#!
#! The management of this problem is done in upstream linux and allows administrators to adjust the way that the management is enforced, for our infrastructure it's expected to enforce full mitigation to comply with paranoid setup.

let
	inherit (lib) mkMerge mkForce mkDefault mkIf;
in {
	config = mkMerge [
		{
			security.allowSimultaneousMultithreading = mkForce false; # Disable Simultaneous Multi-Threading as on this system it exposes unwanted attack vectors

			# Kernel
				boot.kernelParams = mkForce [
					"tsx=auto" # Let Linux Developers determine if the mitigation is needed
					"tsx_async_abort=full,nosmt" # Enforce Full Mitigation if the management is needed
					"mds=off" # Paranoid enforcement, shouldn't be needed..
				];

			# Necessary Evil to keep the CPU microcode up-to-date, such is all i686 and amd64 architecture systems
			hardware.enableRedistributableFirmware = true;
			hardware.cpu.intel.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;
		}

		# Enforce to use the Tor Proxy
		# (mkIf config.services.tor.enable {
		# 	networking.proxy.default = mkDefault "socks5://127.0.0.1:9050";
		# 	networking.proxy.noProxy = mkDefault "127.0.0.1,localhost";
		# })
	];
}
