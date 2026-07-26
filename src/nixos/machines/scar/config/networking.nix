{ lib, ... }:

# Networking management of SCAR

# FIXME-NIXWARE(Krey): Figure out how to port this to nixware

let
	inherit (lib) mkForce;
in {
	# FIXME-QA(Krey): Enable DHCP only on specified adapters
	# FIXME-QA(Krey): Set to false by `/nixos/modules/services/networking/networkmanager.nix`, better management needed
	networking.useDHCP = mkForce true; # Use DHCP on all adapters
	# networking.interfaces.eno1.useDHCP = lib.mkDefault true;

	# Always use network manager for convinience
	# FIXME-QA(Krey): Set to false by `/nixos/modules/services/networking/networkmanager.nix`, better management needed
	networking.networkmanager = {
		enable = mkForce true;
		# wifi.backend = "iwd";
		# dhcp = "internal";
	};

	hardware.wirelessRegulatoryDatabase = true;

	boot.extraModprobeConfig = ''options cfg80211 ieee80211_regdom="CZ"'';

	networking.firewall.allowedTCPPorts = [
		# FIXME-QA(Krey): Make sure to apply these only if the relevant app is used
		21118 # Rust Desk
		1716 # KDE Connect
		40000 # SimpleX (https://github.com/simplex-chat/simplex-chat/issues/3425#issuecomment-2336520556)
	];
}
