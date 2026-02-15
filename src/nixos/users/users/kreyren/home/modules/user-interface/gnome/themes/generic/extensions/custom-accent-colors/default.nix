{ pkgs, lib, nixosConfig, options, ... }:

# Kreyren's configuration of 'custom accent colors' gnome extension

# FIXME(Krey): This is kinda a weird one to manage as in gnome-47 this was added in the gnome itself and we are using multiple themes.. Maybe add this to the generic theme up until gnome-47?
# FIXME-QA(Krey): Add check for the specific gnome version instead

# let
# 	inherit (lib) elem optionalString mkIf mkMerge;
# 	inherit (lib.trivial) release;
# in mkMerge [
# 	{
# 		"${optionalString (elem release [ "23.05" "23.11" "24.05" "24.11" ]) release}" = let
# 				gnomeVersion = pkgs.gnome.gnome-shell.version;
# 			in mkIf nixosConfig.services.xserver.desktopManager.gnome.enable (mkMerge [
# 			{
# 				"${optionalString (elem gnomeVersion [ "42.4" "43.2" "44.2" "45.5" "46.2" ]) gnomeVersion}" = {
# 					home.packages = [ pkgs.gnomeExtensions.custom-accent-colors ]; # Install the extension

# 					dconf.settings = {
# 						"org/gnome/shell/extensions/custom-accent-colors" = {
# 							accent-color = "purple";
# 							theme-flatpak = true; # Use for flatpak
# 							theme-gtk3 = true; # Use for GTK3
# 							theme-shell = true; # Use for shell
# 						};

# 						# Set the extension as a user-theme as it's designed this way to work
# 						"org/gnome/shell/extensions/user-theme" = {
# 							name = "Custom-Accent-Colors";
# 						};
# 					};
# 				};
# 				"47.2" = {
# 					# Deprecated with GNOM v47+
# 				};
# 			}."${gnomeVersion}"
# 		]);
# 		"${optionalString (elem release [ "25.05" "25.11" ]) release}" = let
# 				gnomeVersion = pkgs.gnome-shell.version;
# 			in mkIf nixosConfig.services.desktopManager.gnome.enable (mkMerge [
# 			{
# 				"${optionalString (elem gnomeVersion [ "48.2" "49.2" ]) gnomeVersion}" = {
# 					# Deprecated with GNOM v47+
# 				};
# 			}."${gnomeVersion}"
# 		]);
# 	}."${release}"
# ]

let
	inherit (lib) elem optionalString mkIf mkMerge;
	inherit (lib.trivial) release;
in mkMerge [
	{
		"24.05" = mkIf nixosConfig.services.xserver.desktopManager.gnome.enable {
			home.packages = [ pkgs.gnomeExtensions.custom-accent-colors ]; # Install the extension

			dconf.settings = {
				"org/gnome/shell/extensions/custom-accent-colors" = {
					accent-color = "purple";
					theme-flatpak = true; # Use for flatpak
					theme-gtk3 = true; # Use for GTK3
					theme-shell = true; # Use for shell
				};

				# Set the extension as a user-theme as it's designed this way to work
				"org/gnome/shell/extensions/user-theme" = {
					name = "Custom-Accent-Colors";
				};
			};
		};
		"${optionalString (elem release [ "24.11" "25.05" "25.11" ]) release}" = {
			# Deprecated with GNOME 47
		};
	}."${release}"
]
