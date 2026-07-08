{ lib, pkgs, nixosConfig,... }:

# Global User Management of Packages on GNOME

# FIXME-QA(Krey): This file has a unique situation as in 25.11 the option `services.xserver.desktopManager.gnome.enable` was renamed to `services.desktopManager.enable` which we use as feature-gate to trigger the version-gate which had to been moved to the version-gate's body which make the code look kinda(?) messy, yet maintains the backwards compatibility, tbd if this can be improved

let
	inherit (lib) elem optionalString mkIf mkMerge;
	inherit (lib.trivial) release;
in mkMerge [
	{
		"23.11" = {
			home.packages = mkIf (if elem release [ "26.05" ] then nixosConfig.services.desktopManager.gnome.enable else nixosConfig.services.xserver.desktopManager.gnome.enable) [
				pkgs.gnome.dconf-editor
				pkgs.pinentry-gnome # Needed for inputting passwords
			];
		};

		"${optionalString (elem release [ "24.05" "24.11" "25.05" "26.05" ]) release}" = mkIf (if elem release [ "26.05" ] then nixosConfig.services.desktopManager.gnome.enable else nixosConfig.services.xserver.desktopManager.gnome.enable) {
			home.packages = [
				pkgs.dconf-editor
				pkgs.pinentry-gnome3 # Needed for inputting passwords
			];
		};

		"25.11" = mkIf nixosConfig.services.desktopManager.gnome.enable {
			home.packages = [
				pkgs.pinentry-gnome3 # Needed for inputting passwords
			];
		};
	}."${release}" or (throw "Release is not implemented: ${release}")

	{
		home.packages = [
			pkgs.xdg-desktop-portal-gnome
			pkgs.xdg-desktop-portal
		];
	}
]
