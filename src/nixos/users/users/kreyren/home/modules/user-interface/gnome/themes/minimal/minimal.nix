{ lib, pkgs, nixosConfig, ... }:

# Kreyren's Minimal GNOME Theme

# This theme is mostly used as a fallback in case the other themes fail to deploy on new GNOME release, so keep it simple and compatible

let
	inherit (lib) elem optionalString mkIf mkMerge;
	inherit (lib.trivial) release;
in mkMerge [
	{
		"${optionalString (elem release [ "24.05" "26.05" ]) release}" = mkIf (if elem release [ "26.05" ] then nixosConfig.services.desktopManager.gnome.enable else nixosConfig.services.xserver.desktopManager.gnome.enable) {
			dconf.settings = {
				# Background
					"org/gnome/desktop/background" = {
						#picture-uri="${pkgs.gnome.gnome-backgrounds}/share/backgrounds/gnome/blobs-l.svg";
						picture-uri ="${./wallpaper.jpeg}";
						#picture-uri-dark="${pkgs.gnome.gnome-backgrounds}/share/backgrounds/gnome/blobs-d.svg";
						picture-uri-dark ="${./wallpaper.jpeg}";
					};
					"org/gnome/desktop/screensaver" = {
						picture-uri ="${./lockscreen.jpg}";
						#picture-uri = "${pkgs.gnome.gnome-backgrounds}/share/backgrounds/gnome/blobs-l.svg";
					};
			};
		};
		"${optionalString (elem release [ "24.11" "24.11" "25.05" "25.11" "26.05" ]) release}" = mkIf (if elem release [ "26.05" ] then nixosConfig.services.desktopManager.gnome.enable else nixosConfig.services.xserver.desktopManager.gnome.enable) {
			dconf.settings = {
				# Background
					"org/gnome/desktop/background" = {
						#picture-uri="${pkgs.gnome.gnome-backgrounds}/share/backgrounds/gnome/blobs-l.svg";
						picture-uri ="${./wallpaper.jpeg}";
						#picture-uri-dark="${pkgs.gnome.gnome-backgrounds}/share/backgrounds/gnome/blobs-d.svg";
						picture-uri-dark ="${./wallpaper.jpeg}";
					};
					"org/gnome/desktop/screensaver" = {
						picture-uri ="${./lockscreen.jpg}";
						#picture-uri = "${pkgs.gnome.gnome-backgrounds}/share/backgrounds/gnome/blobs-l.svg";
					};
			};

			dconf.settings."org/gnome/desktop/interface".accent-color = "purple"; # Set Accent Color
		};
	}."${release}"
]
