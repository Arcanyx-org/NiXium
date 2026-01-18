{ lib, config, ... }:

# Security management of SINNENFREUDE

let
	inherit (lib) mkMerge mkForce mkDefault mkIf;
in {
	config = mkMerge [
		{
			security.allowSimultaneousMultithreading = mkForce false; # Vulnerable AF

			# NOTE(Krey): Breaks USB
			security.lockKernelModules = false;

			# NOTE(Krey): Breaks hibernation
			security.protectKernelImage = false;
		}

		# Enforce to use the Tor Proxy
		# NOTE(Krey): It's currently causing issues
		# (mkIf config.services.tor.enable {
		# 	networking.proxy.default = mkDefault "socks5://127.0.0.1:9050";
		# 	networking.proxy.noProxy = mkDefault "127.0.0.1,localhost";
		# })
	];
}
