{ lib, pkgs, nixosConfig, ... }:

# Kreyren's Generic GNOME Theme

# This theme is mostly used as a fallback in case the other themes fail to deploy on new GNOME release, so keep it simple and compatible


# FIXME(Krey): Implement this
# # Gnome-version specific
# 		{
# 			"47.0.1" = {
# 				dconf.settings."org/gnome/desktop/interface".accent-color = "purple"; # Set Accent Color
# 			};
# 		}.${pkgs.gnome-session.version}


let
	inherit (lib) mkIf mkMerge;
in mkIf nixosConfig.services.xserver.desktopManager.gnome.enable (mkMerge [
	# Common Configuration across multiple GNOME releases
		{
			dconf.settings = {
				"org/gnome/desktop/interface" = {
					color-scheme = "prefer-dark"; # Prefer Dark Color Scheme
					gtk-theme = "Adw-gtk3-dark"; # Set Default GNOME Theme
				};

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
		}

		{
			"24.11" = {
				dconf.settings."org/gnome/desktop/interface".accent-color = "purple"; # Set Accent Color
			};
		}.${lib.trivial.release} or (throw "Release '${lib.trivial.release}' is not implemented")
])
