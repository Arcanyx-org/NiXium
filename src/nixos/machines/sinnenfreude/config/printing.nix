{ config, lib, pkgs, ... }:

# Printing Management For SINNENFREUDE

let
	inherit (lib) mkIf;
in mkIf config.services.printing.enable {
	# Discovery is done via the opened UDP port 5353
	services.avahi = {
		enable = true; # Enable the mDNS Reported to allow the local machines to advertise its presence and services
		nssmdns4 = true; # Enable Name Service Switch plug-in for IPv4
	};

	services.printing.enable = true;

	# hardware.printers = {
	# 	ensurePrinters = [
	# 		{
	# 			# Base48 Printer
	# 			name = "Base48_Printer"; # HP_LaserJet_P4015_24B6F0
	# 			description = "Base48 Printer";
	# 			location = "The Base48 Hackerspace";
	# 			# FIXME(Krey): This assumes connection to the local WiFI which i rarelly do -> Figure out ideally Tor or clearweb service
	# 			deviceUri = "ipp://10.48.0.134/ipp";
	# 			# deviceUri = "dnssd://HP%20LaserJet%20P4015%20%5B24B6F0%5D._printer._tcp.local/";
	# 			# deviceUri = "ipp://10.48.0.134/ipp";
	# 			# Use `lpinfo -m` to find
	# 			# model = "HP/hp-laserjet_p4015.ppd.gz"; # HP LaserJet Series PCL 4/5 (grayscale)
	# 			# model = "${pkgs.hplip}/share/cusp/modoel/HP/hp-laserjet_p4015.ppd.gz";
	# 			model = "everywhere";
	# 			ppdOptions = {
	# 				PageSize = "A4";
	# 			};

	# 			# Thermal printer
	# 			# name = "Base48-POS";
	# 			# deviceUri = ""
	# 		}
	# 	];
	# };

	services.printing.drivers = [
		pkgs.gutenprint # Generic open-source
	];
}
