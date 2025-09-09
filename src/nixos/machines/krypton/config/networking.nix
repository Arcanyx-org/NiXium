{ config, lib, ... }:

# Networking Management of TEMPLATE

let
	inherit (lib) mkForce mkIf;
in {
	# Adapters that are allowed to use DHCP
	networking.interfaces.wlan0.useDHCP = true;
	networking.interfaces.wlan1.useDHCP = true;
	# FIXME(Krey): This should be in docker's module
		networking.interfaces.docker0.useDHCP = mkIf config.virtualisation.docker.enable true;
}
