{ ... }:

# Security management of TUPAC

{
	# NOTE(Krey): Make it impossible to hibernate
	security.protectKernelImage = false;

	# NOTE(Krey): Experiment
	security.lockKernelModules = false;

	# config = mkMerge [
	# 	# Enforce to use the Tor Proxy
	# 	# NOTE(Krey): It's currently causing issues
	# 	# (mkIf config.services.tor.enable {
	# 	# 	networking.proxy.default = mkDefault "socks5://127.0.0.1:9050";
	# 	# 	networking.proxy.noProxy = mkDefault "127.0.0.1,localhost";
	# 	# })
	# ];
}
