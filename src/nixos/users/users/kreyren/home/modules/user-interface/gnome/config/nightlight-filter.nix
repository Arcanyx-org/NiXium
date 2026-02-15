{ lib, nixosConfig, ... }:

# Kreyren's Module for Adjusting the Nightlight (blu-light filter) on GNOME

let
	inherit (lib) elem optionalString mkIf mkMerge;
	inherit (lib.trivial) release;

	inherit (lib.hm.gvariant) mkUint32;
in mkMerge [
	{
		"${optionalString (elem release [ "24.05" "24.11" "25.05" ]) release}" = mkIf nixosConfig.services.xserver.desktopManager.gnome.enable {
			dconf.settings = {
				"org/gnome/settings-daemon/plugins/color" = {
						night-light-enabled = true;
						night-light-schedule-automatic = true; # From Sunset to Sunrise
						night-light-temperature = mkUint32 1700; # 4700~1700
					};
			};
		};
		"25.11" = mkIf nixosConfig.services.desktopManager.gnome.enable {
			dconf.settings = {
				"org/gnome/settings-daemon/plugins/color" = {
						night-light-enabled = true;
						night-light-schedule-automatic = true; # From Sunset to Sunrise
						night-light-temperature = mkUint32 1700; # 4700~1700
					};
			};
		};
	}."${release}"
]
