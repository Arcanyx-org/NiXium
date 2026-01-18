{ lib, ... }:

# Networking Management of MRACEK

let
	inherit (lib) mkForce;
in {
	# FIXME-QA(Krey): Enable DHCP only on specified adapters
	# FIXME-QA(Krey): Set to false by `/nixos/modules/services/networking/networkmanager.nix`, better management needed
	networking.useDHCP = mkForce true; # Use DHCP on all adapters
	# networking.interfaces.eno1.useDHCP = lib.mkDefault true;

	# Always use network manager for convinience
	# FIXME-QA(Krey): Set to false by `/nixos/modules/services/networking/networkmanager.nix`, better management needed
	networking.networkmanager.enable = mkForce true;
}
