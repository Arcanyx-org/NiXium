{ self, config, lib, pkgs, ... }:

# The Base48 Hackerspace Nix module exposing priviledged access to the infrastructure

let
	inherit (lib) mkMerge;
in mkMerge ([
	# Website
		{
			# Set Tor Map Address
				age.secrets.b48-website-mapAddress = {
					file = "${self.outPath}/src/nixos/secrets/b48-website-mapAddress.age";

					owner = "tor";
					group = "tor";

					path = "${config.services.tor.settings.DataDirectory}/conf/b48-website-onion.conf";

					symlink = false; # Appears to not work as symlink
				};

				services.tor.settings."%include" = [ config.age.secrets."b48-website-mapAddress".path ];
		}
	# Home Assistant
		{
			# Set Tor Map Address
				age.secrets.b48-home-assistant-mapAddress = {
					file = "${self.outPath}/src/nixos/secrets/b48-home-assistant-mapAddress.age";

					owner = "tor";
					group = "tor";

					path = "${config.services.tor.settings.DataDirectory}/conf/b48-home-assistant-onion.conf";

					symlink = false; # Appears to not work as symlink
				};

				services.tor.settings."%include" = [ config.age.secrets."b48-home-assistant-mapAddress".path ];
		}
	#-- FDM Printer Charlotte --#
		{
			# Set Tor Client Authorization
				age.secrets.b48-fdm-printer-charlotte-auth = {
					file = "${self.outPath}/src/nixos/secrets/b48-fdm-printer-charlotte-auth.age";

					owner = "tor";
					group = "tor";

					path = "${config.services.tor.settings.DataDirectory}/onion_auth/b48-fdm-printer-charlotte-auth.auth_private";

					symlink = false; # Appears to not work as symlink
				};

			# Set Tor Map Address
				age.secrets.b48-fdm-printer-charlotte-mapAddress = {
					file = "${self.outPath}/src/nixos/secrets/b48-fdm-printer-charlotte-mapAddress.age";

					owner = "tor";
					group = "tor";

					path = "${config.services.tor.settings.DataDirectory}/conf/b48-fdm-printer-charlotte-onion.conf";

					symlink = false; # Appears to not work as symlink
				};

				services.tor.settings."%include" = [ config.age.secrets."b48-fdm-printer-charlotte-mapAddress".path ];
		}

	#-- FDM Printer Ondrej --#
		{
			# Set Tor Client Authorization
				age.secrets.b48-fdm-printer-ondrej-auth = {
					file = "${self.outPath}/src/nixos/secrets/b48-fdm-printer-ondrej-auth.age";

					owner = "tor";
					group = "tor";

					path = "${config.services.tor.settings.DataDirectory}/onion_auth/b48-fdm-printer-ondrej-auth.auth_private";

					symlink = false; # Appears to not work as symlink
				};

			# Set Tor Map Address
				age.secrets.b48-fdm-printer-ondrej-mapAddress = {
					file = "${self.outPath}/src/nixos/secrets/b48-fdm-printer-ondrej-mapAddress.age";

					owner = "tor";
					group = "tor";

					path = "${config.services.tor.settings.DataDirectory}/conf/b48-fdm-printer-ondrej-auth.conf";

					symlink = false; # Appears to not work as symlink
				};

				services.tor.settings."%include" = [ config.age.secrets."b48-fdm-printer-ondrej-mapAddress".path ];
		}

	#-- FDM Printer Plague --#
		{
			# Set Tor Client Authorization
				age.secrets.b48-fdm-printer-plague-auth = {
					file = "${self.outPath}/src/nixos/secrets/b48-fdm-printer-plague-auth.age";

					owner = "tor";
					group = "tor";

					path = "${config.services.tor.settings.DataDirectory}/onion_auth/b48-fdm-printer-plague-auth.auth_private";

					symlink = false; # Appears to not work as symlink
				};

			# Set Tor Map Address
				age.secrets.b48-fdm-printer-plague-mapAddress = {
					file = "${self.outPath}/src/nixos/secrets/b48-fdm-printer-plague-mapAddress.age";

					owner = "tor";
					group = "tor";

					path = "${config.services.tor.settings.DataDirectory}/conf/b48-fdm-printer-plague-onion.conf";

					symlink = false; # Appears to not work as symlink
				};

				services.tor.settings."%include" = [ config.age.secrets."b48-fdm-printer-plague-mapAddress".path ];
		}

	#-- FDM Printer Vidi --#
		{
			# Set Tor Client Authorization
				age.secrets.b48-fdm-printer-vidi-auth = {
					file = "${self.outPath}/src/nixos/secrets/b48-fdm-printer-vidi-auth.age";

					owner = "tor";
					group = "tor";

					path = "${config.services.tor.settings.DataDirectory}/onion_auth/b48-fdm-printer-vidi-auth.auth_private";

					symlink = false; # Appears to not work as symlink
				};

			# Set Tor Map Address
				age.secrets.b48-fdm-printer-vidi-mapAddress = {
					file = "${self.outPath}/src/nixos/secrets/b48-fdm-printer-vidi-mapAddress.age";

					owner = "tor";
					group = "tor";

					path = "${config.services.tor.settings.DataDirectory}/conf/b48-fdm-printer-vidi-onion.conf";

					symlink = false; # Appears to not work as symlink
				};

				services.tor.settings."%include" = [ config.age.secrets."b48-fdm-printer-vidi-mapAddress".path ];
		}

	#-- FDM Printer Wine --#
		{
			# Set Tor Client Authorization
				age.secrets.b48-fdm-printer-wine-auth = {
					file = "${self.outPath}/src/nixos/secrets/b48-fdm-printer-wine-auth.age";

					owner = "tor";
					group = "tor";

					path = "${config.services.tor.settings.DataDirectory}/onion_auth/b48-fdm-printer-wine-auth.auth_private";

					symlink = false; # Appears to not work as symlink
				};

			# Set Tor Map Address
				age.secrets.b48-fdm-printer-wine-mapAddress = {
					file = "${self.outPath}/src/nixos/secrets/b48-fdm-printer-wine-mapAddress.age";

					owner = "tor";
					group = "tor";

					path = "${config.services.tor.settings.DataDirectory}/conf/b48-fdm-printer-wine-onion.conf";

					symlink = false; # Appears to not work as symlink
				};

				services.tor.settings."%include" = [ config.age.secrets."b48-fdm-printer-wine-mapAddress".path ];
		}

	# #-- InkJet Printer --#
		{
			# Set Tor Client Authorization
				age.secrets.b48-paper-printer-auth = {
					file = "${self.outPath}/src/nixos/secrets/b48-paper-printer-auth.age";

					owner = "tor";
					group = "tor";

					path = "${config.services.tor.settings.DataDirectory}/onion_auth/b48-paper-printer-auth.auth_private";

					symlink = false; # Appears to not work as symlink
				};

			# Set Tor Map Address
				age.secrets.b48-paper-printer-mapAddress = {
					file = "${self.outPath}/src/nixos/secrets/b48-paper-printer-mapAddress.age";

					owner = "tor";
					group = "tor";

					path = "${config.services.tor.settings.DataDirectory}/conf/b48-paper-printer-onion.conf";

					symlink = false; # Appears to not work as symlink
				};

				services.tor.settings."%include" = [ config.age.secrets."b48-paper-printer-mapAddress".path ];

			# Add to CUPS
				hardware.printers = {
					ensurePrinters = [
						{
							# Base48 Printer
							name = "Base48_Printer"; # HP_LaserJet_P4015_24B6F0
							description = "Base48 Printer";
							location = "The Base48 Hackerspace";
							# deviceUri = "ipp://paper.base48.cz/ipp"; # Tor MapAddressed URL
							deviceUri = "ipp://10.48.0.134/ipp";
							model = "everywhere";
							ppdOptions = {
								PageSize = "A4";
							};
						}
					];
				};

				# The printer firmware returns malformed IPP which violates RFC 8011 section 5.1.6 and causes cups to throw an RFC-mandated error, thi is a workaround as `raw` is getting deprecated
					# networking.hosts = { "127.0.0.1" = [ "paper.base48.cz" ]; };

					# systemd.services.ippTorProxy = let
					# 	localIppPort = 16311;
					# 	onionHost = "paper.base48.cz"; # your .onion hostname
					# 	onionPort = 631;
					# in {
					# 	description = "Local IPP proxy forwarding to printer via Tor";
					# 	wantedBy = [ "multi-user.target" ];
					# 	after = [ "network.target" "tor.service" ];

					# 	serviceConfig = {
					# 		Type = "simple";
					# 		ExecStart = "''
					# 			${pkgs.socat}/bin/socat \
					# 				TCP-LISTEN:${toString localIppPort},fork,reuseaddr \
					# 				SOCKS5:127.0.0.1:${onionHost}:${toString onionPort},socksport=9050
					# 		''";
					# 		Restart = "always";
					# 		RestartSec = 5;
					# 	};
					# };
		}
])
