{ config, lib, ... }:

# Networking Management of IGNUCIUS

let
	inherit (lib) mkForce mkIf;
in {
	# Adapters that are allowed to use DHCP
	networking.interfaces.wlp2s0.useDHCP = true;
	# FIXME(Krey): This doesn't seem to work?
		networking.interfaces.docker0.useDHCP = true;
		# networking.interfaces.docker0.useDHCP = mkIf config.virtualisation.docker.enable;
	networking.interfaces.wwp0s29u1u4i6.useDHCP = true;

	# Always use network manager for convinience
	# FIXME-QA(Krey): Set to false by `/nixos/modules/services/networking/networkmanager.nix`, better management needed
	networking.networkmanager.enable = mkForce true;

	# Add firewall exception for SimpleX (https://github.com/simplex-chat/simplex-chat/issues/3425#issuecomment-2336520556)
	networking.firewall.allowedTCPPorts = [ 40000 ];
}
