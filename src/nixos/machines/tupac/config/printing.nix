{ config, lib, pkgs, ... }:

# Printing Management For TUPAC

let
	inherit (lib) mkIf mkForce;
in mkIf config.services.printing.enable {
	# Discovery is done via the opened UDP port 5353
	services.avahi = {
		enable = true; # Enable the mDNS Reported to allow the local machines to advertise its presence and services
		nssmdns4 = true; # Enable Name Service Switch plug-in for IPv4
	};

	hardware.printers = {
		ensurePrinters = [
			{
				# Base48 Printer
				name = "Base48_Printer"; # HP_LaserJet_P4015_24B6F0
				description = "Base48 Printer";
				location = "The Base48 Hackerspace";
				# FIXME(Krey): This assumes connection to the local WiFI which i rarelly do -> Figure out ideally Tor or clearweb service
				# FIXME(Krey): This works, but it's causing the service to fail after evaluation as ensurePrinters is trying to reach the system..
				deviceUri = "ipp://10.48.0.134/ipp";
				# deviceUri = "dnssd://HP%20LaserJet%20P4015%20%5B24B6F0%5D._printer._tcp.local/";
				# deviceUri = "ipp://10.48.0.134/ipp";
				# Use `lpinfo -m` to find
				# model = "HP/hp-laserjet_p4015.ppd.gz"; # HP LaserJet Series PCL 4/5 (grayscale)
				# model = "${pkgs.hplip}/share/cusp/modoel/HP/hp-laserjet_p4015.ppd.gz";
				model = "everywhere";
				ppdOptions = {
					PageSize = "A4";
				};

				# Thermal printer
				# name = "Base48-POS";
				# deviceUri = ""
			}
		];
	};

	services.printing.drivers = [
		pkgs.gutenprint # Generic open-source
	];

	# FIXME(Krey): It's throwing fail unless i am in the hackerspace
		# × ensure-printers.service - Ensure NixOS-configured CUPS printers
    # 	Loaded: loaded (/etc/systemd/system/ensure-printers.service; enabled; preset: ignored)
    # 	Active: failed (Result: exit-code) since Fri 2025-08-01 07:29:00 CEST; 292ms ago
		# Invocation: 17b530bb6cfc46f281554915bd2ac5b8
		# 		Process: 399467 ExecStart=/nix/store/hyfqynk97fb351mlxsny5kvihxd4v1dv-unit-script-ensure-printers-start/bin/ensure-printers-start (code=exited, status=1/FAILURE)
		# 	Main PID: 399467 (code=exited, status=1/FAILURE)
		# 				IP: 0B in, 0B out
		# 				IO: 416K read, 0B written
		# 	Mem peak: 2.8M
		# 				CPU: 12ms
	# systemd.services.ensurePrinters.serviceConfig.SuccessExitStatus = mkForce "0 1";
}
