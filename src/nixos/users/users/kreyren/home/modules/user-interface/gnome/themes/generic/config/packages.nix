{ config, lib, pkgs, nixosConfig,... }:

# Management of needed packages for Krey's Generic GNOME Theme

let
	inherit (lib) mkIf mkMerge;
in mkIf nixosConfig.services.xserver.desktopManager.gnome.enable (mkMerge [
	{
		"24.05" = {
			home.packages = [];
		};
		"24.11" = {
			home.packages = [];
		};
		"25.05" = {
			home.packages = [];
		};
	}."${lib.trivial.release}" or (throw "Release is not implemented: ${lib.trivial.release}")

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
