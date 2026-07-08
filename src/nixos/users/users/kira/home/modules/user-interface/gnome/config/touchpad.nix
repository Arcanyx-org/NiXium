{ lib, pkgs, config, nixosConfig, ... }:

# Kira's Module for Touchpad Managements on GNOME

let
	inherit (lib) elem mkIf mkMerge;
	inherit (lib.trivial) release;
in mkIf (if elem release [ "26.05" ] then nixosConfig.services.desktopManager.gnome.enable else nixosConfig.services.xserver.desktopManager.gnome.enable) (mkMerge [
	# Common Configuration across multiple GNOME releases
		{
			dconf.settings = {
				"org/gnome/desktop/peripherals/touchpad" = {
					edge-scrolling-enabled = false;
					natural-scroll = true;
					two-finger-scrolling-enabled = true;
				};
			};
		}
])
