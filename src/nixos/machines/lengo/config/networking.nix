{ config, lib, ... }:

# Networking Management of LENGO

let
	inherit (lib) mkForce mkIf;
in {
	# Set adapters that are allowed to use DHCP
		networking.useDHCP = mkForce true;
		# networking.interfaces.wlp1s0.useDHCP = true;
		# FIXME(Krey): This should be in docker's module
			# networking.interfaces.docker0.useDHCP = mkIf config.virtualisation.docker.enable true;

	# Always use network manager for convinience
		# FIXME-QA(Krey): Set to false by `/nixos/modules/services/networking/networkmanager.nix`, better management needed
		networking.networkmanager.enable = mkForce true;

	#! Unreliable WiFi Adapter Issue
	#! - The device uses MediaTek MT7922 Network Controller fails to connect to a password-protected WiFi
	#! - Tried to include wireless Regulatory Database which doesn't seem to help
		# For the MediaTek chip, you will be limited to 802.11n (WiFi 4) and 2.4GHz bands if you do not configure the regulatory domain (https://community.frame.work/t/nixos-on-framework-laptop-13/31426/77)
			hardware.wirelessRegulatoryDatabase = true;
			boot.extraModprobeConfig = ''options cfg80211 ieee80211_regdom="CZ"'';
	#! - The device claims to have
		hardware.enableAllFirmware = true; # Desperation, remove when able
		# FIXME(Krey): `wpa_supplicant` causes issues connecting to password protected networks, but it happens on iwd too
		# networking.networkmanager.wifi.backend = "iwd";
}
