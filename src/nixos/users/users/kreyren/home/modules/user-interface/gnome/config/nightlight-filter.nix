{ lib, nixosConfig, ... }:

# Kreyren's Module for Adjusting the Nightlight (blu-light filter) on GNOME

let
	inherit (lib) mkIf mkMerge;
	inherit (lib.hm.gvariant) mkUint32;
in mkIf nixosConfig.services.xserver.desktopManager.gnome.enable (mkMerge [
	# Common Configuration across multiple GNOME releases
		{
			dconf.settings = {
				"org/gnome/settings-daemon/plugins/color" = {
						night-light-enabled = true;
						night-light-schedule-automatic = true; # From Sunset to Sunrise
						night-light-temperature = mkUint32 1700; # 4700~1700
					};
			};
		}
])
