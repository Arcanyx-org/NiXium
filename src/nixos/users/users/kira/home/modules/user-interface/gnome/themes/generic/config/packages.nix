{ config, lib, pkgs, nixosConfig,... }:

# Management of needed packages for Kira's Generic GNOME Theme

let
	inherit (lib) elem mkIf mkMerge optionalString;
	inherit (lib.trivial) release;
in mkIf (if elem release [ "26.05" ] then nixosConfig.services.desktopManager.gnome.enable else nixosConfig.services.xserver.desktopManager.gnome.enable) (mkMerge [
	{
		"${optionalString (elem release [ "24.05" "24.11" "25.05" "25.11" "26.05" ]) release}" = {
			home.packages = [];
		};
	}."${release}" or (throw "Release is not implemented: ${release}")

	{
		home.packages = [
			# Include the expected extensions
				pkgs.gnomeExtensions.removable-drive-menu
				pkgs.gnomeExtensions.vitals
				pkgs.gnomeExtensions.blur-my-shell
				pkgs.gnomeExtensions.gsconnect
				pkgs.gnomeExtensions.desktop-cube
				pkgs.gnomeExtensions.burn-my-windows
				pkgs.gnomeExtensions.caffeine
		];
	}
])
