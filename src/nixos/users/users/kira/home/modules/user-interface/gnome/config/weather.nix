{ lib, nixosConfig, ... }:

# Kira's Module for Weather Configuration on GNOME

let
	inherit (lib) elem mkIf mkMerge;
	inherit (lib.trivial) release;
in mkIf (if elem release [ "26.05" ] then nixosConfig.services.desktopManager.gnome.enable else nixosConfig.services.xserver.desktopManager.gnome.enable) (mkMerge [
	# Common Configuration across multiple GNOME releases
		{
			dconf.settings = {
				"org/gnome/shell/weather" = {
					automatic-location = true;
				};

				# Set the weather app in Kelvin #KelvinGang
				"org/gnome/GWeather4" = {
					# NOTE(Krey): Should probably change this to celsius, but lets see how this goes :3
					temperature-unit = "kelvin";
				};
			};
		}
])
