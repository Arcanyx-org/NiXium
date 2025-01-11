{ lib, ... }:

# Networking Management of FLEXY

let
	inherit (lib) mkForce;
in {
	networking.interfaces.wlp2s0.useDHCP = true; # Use DHCP on the main WiFi adapter

	# Always use network manager for convinience
	# FIXME-QA(Krey): Set to false by `/nixos/modules/services/networking/networkmanager.nix`, better management needed
	networking.networkmanager.enable = mkForce true;
}
