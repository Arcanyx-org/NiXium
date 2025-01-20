{ config, lib, ... }:

# WiFi Management Module

let
	inherit (lib) mkIf;
in mkIf config.networking.networkmanager.enable {
	# Authentificate to the hidden WiFi Network for Kreyren's Home Base
	age.secrets.home-wifi-psk = {
		file = ./homeBaseKreyren-WiFi-PSK.age;
		path = "/etc/NetworkManager/system-connections/homeBaseKreyren.nmconnection";
	};
}
