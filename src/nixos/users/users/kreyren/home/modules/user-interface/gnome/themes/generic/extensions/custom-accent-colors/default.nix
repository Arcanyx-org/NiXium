{ self, pkgs, lib, nixosConfig, ... }:

# Kreyren's configuration of 'custom accent colors' gnome extension

# FIXME(Krey): This is kinda a weird one to manage as in gnome-47 this was added in the gnome itself and we are using multiple themes.. Maybe add this to the generic theme up until gnome-47?

let
	inherit (lib) mkIf;
in mkIf nixosConfig.services.xserver.desktopManager.gnome.enable {
	"24.05" = {
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

	"24.11" = {
		# Deprecated with GNOME 47
	};
	# FIXME-QA(Krey): Duplicate code
	"25.05" = {
		# Deprecated with GNOME 47
	};
}."${lib.trivial.release}" or (throw "The NixOS Release '${lib.trivial.release}' is not implemented")
