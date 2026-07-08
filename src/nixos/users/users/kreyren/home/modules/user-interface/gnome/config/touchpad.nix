{ lib, pkgs, config, nixosConfig, ... }:

# Kreyren's Module for Touchpad Managements on GNOME

let
	inherit (lib) elem optionalString mkIf mkMerge;
	inherit (lib.trivial) release;
in mkMerge [
	{
		"${optionalString (elem release [ "24.05" "24.11" "25.05" "26.05" ]) release}" = mkIf (if elem release [ "26.05" ] then nixosConfig.services.desktopManager.gnome.enable else nixosConfig.services.xserver.desktopManager.gnome.enable) {
			dconf.settings = {
				"org/gnome/desktop/peripherals/touchpad" = {
						edge-scrolling-enabled = false;
						natural-scroll = true;
						two-finger-scrolling-enabled = true;
					};
			};
		};
		"25.11" = mkIf nixosConfig.services.desktopManager.gnome.enable {
			dconf.settings = {
				"org/gnome/desktop/peripherals/touchpad" = {
						edge-scrolling-enabled = false;
						natural-scroll = true;
						two-finger-scrolling-enabled = true;
					};
			};
		};
	}."${release}" or (throw "Release is not implemented: ${release}")
]
