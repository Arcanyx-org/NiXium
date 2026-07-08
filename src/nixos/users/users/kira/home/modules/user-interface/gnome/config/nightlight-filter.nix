{ lib, nixosConfig, ... }:

# Kira's Module for Adjusting the Nightlight (blue-light filter) on GNOME

let
	inherit (lib) elem mkIf mkMerge;
	inherit (lib.trivial) release;
	inherit (lib.hm.gvariant) mkUint32;
in mkIf (if elem release [ "26.05" ] then nixosConfig.services.desktopManager.gnome.enable else nixosConfig.services.xserver.desktopManager.gnome.enable) (mkMerge [
	# Common Configuration across multiple GNOME releases
		{
			dconf.settings = {
				"org/gnome/settings-daemon/plugins/color" = {
						night-light-enabled = true;
						night-light-schedule-automatic = true; # From Sunset to Sunrise
						night-light-temperature = mkUint32 2954; # 4700~1700
					};
			};
		}
])
