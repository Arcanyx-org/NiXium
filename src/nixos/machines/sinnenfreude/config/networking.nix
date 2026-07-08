{ lib, ... }:

# Networking Management of SINNENFREUDE

{
	# Always use network manager for convinience
	networking.networkmanager.enable = true;

	networking.firewall.allowedTCPPorts = [
		# FIXME-QA(Krey): Make sure to apply these only if the relevant app is used
		21118 # Rust Desk
		1716 # KDE Connect
		40000 # SimpleX (https://github.com/simplex-chat/simplex-chat/issues/3425#issuecomment-2336520556)
	];
}
