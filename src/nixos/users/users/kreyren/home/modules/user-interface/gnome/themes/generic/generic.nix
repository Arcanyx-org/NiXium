{ lib, pkgs, nixosConfig, ... }:

# Kreyren's Generic GNOME Theme

# This theme is mostly used as a fallback in case the other themes fail to deploy on new GNOME release, so keep it simple and compatible


let
	inherit (lib) mkIf optionalString elem mkMerge;
	inherit (lib.trivial) release;
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

				# Setup Extensions
					"org/gnome/shell" = {
						disable-user-extensions = false;

						# The extension names can be found through `$ gnome-extensions list`
						enabled-extensions = [
							pkgs.gnomeExtensions.removable-drive-menu.extensionUuid
							pkgs.gnomeExtensions.vitals.extensionUuid
							pkgs.gnomeExtensions.blur-my-shell.extensionUuid
							pkgs.gnomeExtensions.gsconnect.extensionUuid
							pkgs.gnomeExtensions.desktop-cube.extensionUuid
							pkgs.gnomeExtensions.caffeine.extensionUuid
							pkgs.gnomeExtensions.space-bar.extensionUuid
						];

						disabled-extensions = [];
					};
			};
		}

		{
			"24.05" = {
				# This extension has been implemented in GNOME starting Nixpkgs >=24.11
				dconf.settings."org/gnome/shell".enabled-extensions = [ "custom-accent-colors@demiskp" ]; # Enable custom accent color
			};
			"${optionalString (elem release [ "24.11" "25.05" "25.11" ]) release}" = {
				dconf.settings."org/gnome/desktop/interface".accent-color = "purple"; # Set Accent Color
			};
		}.${release} or (throw "Release '${release}' is not implemented")
])
