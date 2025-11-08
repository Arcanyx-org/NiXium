{ config, lib, ... }:

# Networking Management of TWINKCENTRAL

let
	inherit (lib) mkForce mkIf;
in {
	# Adapters that are allowed to use DHCP
	networking.interfaces.enp8s0f0.useDHCP = true;
	networking.interfaces.wlp6s0.useDHCP = true;
	# FIXME(Krey): This should be in docker's module
		networking.interfaces.docker0.useDHCP = mkIf config.virtualisation.docker.enable true;

	# Always use network manager for convinience
	# FIXME-QA(Krey): Set to false by `/nixos/modules/services/networking/networkmanager.nix`, better management needed
	networking.networkmanager.enable = mkForce true;
}
