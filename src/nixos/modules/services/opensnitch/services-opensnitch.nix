{ config, pkgs, lib, ... }:

# Global Configuration of OpenSnitch

let
	inherit (lib) mkIf mkMerge;
in mkIf config.services.opensnitch.enable (mkMerge [
	{
		# NOTE(Krey): If GUI is running it's configuration overwrites the daemon
		services.opensnitch.settings.DefaultAction = "deny";

		services.opensnitch.rules = {
			# FIXME-PRIVACY(Krey): Should go over VPN
			systemd-timesyncd = {
				name = "systemd-timesyncd";
				enabled = true;
				action = "allow";
				duration = "always";
				operator = {
					type = "simple";
					sensitive = false;
					operand = "process.path";
					data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-timesyncd";
				};
			};
			# FIXME-PRIVACY(Krey): Should go over VPN
			systemd-resolved = {
				name = "systemd-resolved";
				enabled = true;
				action = "allow";
				duration = "always";
				operator = {
					type = "simple";
					sensitive = false;
					operand = "process.path";
					data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-resolved";
				};
			};
			cupsd = {
				name = "cupsd";
				enabled = true;
				action = "allow";
				duration = "always";
				operator = {
					type = "simple";
					sensitive = false;
					operand = "process.path";
					data = "${lib.getBin pkgs.cups}/bin/cupsd";
				};
			};

			# TODO(Krey): Add KDE Connect https://github.com/evilsocket/opensnitch/discussions/1141

			# TODO(Krey): Add localhost https://github.com/evilsocket/opensnitch/issues/982#issuecomment-1621452594

			# Gnome-calc pings the IMF to get exchange rates https://github.com/evilsocket/opensnitch/discussions/1283
				# FIXME-PRIVACY(Krey): Use Tor instead
			gnome-calc = {
				name = "Block calculator from any network access";
				enabled = true;
				action = "deny";
				duration = "always";
				operator =
						{
						type = "simple";
						sensitive = false;
						operand = "process.path";
						data = "${lib.getBin pkgs.gnome-calculator}/bin/.gnome-calculator-wrapped";
						};
				};
		};
	}

	# Allow NSNCD (default=on)
	(mkIf config.services.nscd.enableNsncd {
		services.opensnitch.rules = {
			"nscd" = {
				"name" = "tor";
				"description" = "Permit the nsncd daemon";
				"enabled" = true;
				"action" = "allow";
				"duration" = "always";
				"operator" = {
					"type" ="simple";
					"sensitive" = false;
					"operand" = "process.path";
					"data" = "${lib.getBin pkgs.nsncd}/bin/nsncd";
				};
			};
		};
	})

	# Allow Tor Connection
	(mkIf config.services.tor.enable {
		services.opensnitch.rules = {
			"tor" = {
				"name" = "tor";
				"description" = "Permit the Tor daemon";
				"enabled" = true;
				"action" = "allow";
				"duration" = "always";
				"operator" = {
					"type" ="simple";
					"sensitive" = false;
					"operand" = "process.path";
					"data" = "${lib.getBin pkgs.tor}/bin/tor";
				};
			};
		};
	})
])
