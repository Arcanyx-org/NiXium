{ lib, pkgs, nixosConfig,  ... }:

# Global User Management of GNOME-related packages that are needed to make GNOME to run well

# DNM(Krey): I fucked up this file soooo bad... needs to be remanabed

let
	inherit (lib) elem optionalString mkIf mkMerge;
	inherit (lib.trivial) release;

	# FIXME-REL(Krey): `services.xserver.desktopManager.gnome.enable` has been renamed in 25.11 to use `desktopManager.gnome.enable` which needs to be adjusted
in mkIf nixosConfig.services.xserver.desktopManager.gnome.enable (mkMerge [
	{
		"23.11" = {
			home.packages = [
				pkgs.gnome.dconf-editor
				pkgs.pinentry-gnome # Needed for inputting passwords
			];
		};

		"24.05" = {
			home.packages = [
				pkgs.gnome.dconf-editor
				pkgs.pinentry-gnome3 # Needed for inputting passwords

				# To manage pipewire
				(mkIf nixosConfig.services.pipewire.enable pkgs.helvum)
			];
		};

		"${optionalString (elem release [ "24.11" "25.05" "25.11" ]) release}" = {
			home.packages = [
				pkgs.dconf-editor
				pkgs.pinentry-gnome3 # Needed for inputting passwords

				# To manage pipewire
				(mkIf nixosConfig.services.pipewire.enable pkgs.helvum)
			];
		};
	}."${release}" or (throw "Release not implemented: ${release}")
])
