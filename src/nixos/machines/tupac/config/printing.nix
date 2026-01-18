{ config, lib, ... }:

# Printing Management For TUPAC

let
	inherit (lib) mkIf;
in mkIf config.services.printing.enable {
	# Discovery is done via the opened UDP port 5353
	services.avahi = {
		enable = true; # Enable the mDNS Reported to allow the local machines to advertise its presence and services
		nssmdns4 = true; # Enable Name Service Switch plug-in for IPv4
	};
}
