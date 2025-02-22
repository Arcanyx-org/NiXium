{ lib, nixosConfig, ... }:

# Kira's Module for Weather Configuration on GNOME

let
	inherit (lib) mkIf mkMerge;
in mkIf nixosConfig.services.xserver.desktopManager.gnome.enable (mkMerge [
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
