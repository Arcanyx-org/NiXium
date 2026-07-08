{ lib, config, pkgs, ... }:

# ClamAV configuration

let
	inherit (lib) mkIf;
in mkIf config.services.clamav.daemon.enable {
	environment.systemPackages = [ pkgs.clamtk ]; # Install clamtk system-wide if clamav is used so that it's available to the users

	services.clamav.updater.enable = true; # Daemon to update malware definitions

	# Network-dependent — retry if database.clamav.net is unreachable at boot
	systemd.services.clamav-freshclam = {
		serviceConfig = {
			Restart = "on-failure";
			RestartSec = 30;
		};
	};

	# OpenSnitch
		# FIXME-PRIVACY(Krey): Should go over Tor
	services.opensnitch.rules = mkIf config.services.opensnitch.enable {
		freshclam= {
			name = "Allow clamav to update signatures";
			enabled = true;
			action = "allow";
			duration = "always";
			operator = {
				type = "list";
				operand = "list";
				list = [
					{
						type = "simple";
						sensitive = false;
						operand = "process.path";
						data = "${lib.getBin pkgs.clamav}/bin/freshclam";
					}
					{
						type = "simple";
						operand = "dest.host";
						sensitive = false;
						data = "database.clamav.net";
					}
				];
			};
		};
	};

	# Impermanence
	environment.persistence."/nix/persist/system".directories = mkIf config.boot.impermanence.enable [
		(mkIf config.services.clamav.daemon.enable config.services.clamav.updater.settings.DatabaseDirectory) # ClamAV
	];
}
