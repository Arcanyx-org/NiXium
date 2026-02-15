{ lib, nixosConfig, ... }:

# Kreyren's Module for Weather Configuration on GNOME

let
	inherit (lib) elem optionalString mkIf mkMerge;
	inherit (lib.trivial) release;
in mkMerge [
	{
		"${optionalString (elem release [ "24.05" "24.11" "25.05" ]) release}" = mkIf nixosConfig.services.xserver.desktopManager.gnome.enable {
			dconf.settings = {
				"org/gnome/shell/weather" = {
						automatic-location = true;
					};

					# Set the weather app in Kelvin #KelvinGang
					"org/gnome/GWeather4" = {
						temperature-unit = "kelvin";
					};
			};
		};
		"25.11" = mkIf nixosConfig.services.desktopManager.gnome.enable {
			dconf.settings = {
				"org/gnome/shell/weather" = {
						automatic-location = true;
					};

					# Set the weather app in Kelvin #KelvinGang
					"org/gnome/GWeather4" = {
						temperature-unit = "kelvin";
					};
			};
		};
	}."${release}"
]
