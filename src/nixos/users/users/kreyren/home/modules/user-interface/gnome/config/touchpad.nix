{ lib, pkgs, config, nixosConfig, ... }:

# Kreyren's Module for Touchpad Managements on GNOME

let
	inherit (lib) mkIf mkMerge;
in mkIf nixosConfig.services.xserver.desktopManager.gnome.enable (mkMerge [
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
