{ lib, pkgs, nixosConfig,... }:

# Management of needed packages for Krey's Generic GNOME Theme

let
	inherit (lib) elem optionalString mkIf mkMerge;
	inherit (lib.trivial) release;
in mkMerge [
	{
		"${optionalString (elem release [ "24.05" "24.11" "25.05" "26.05" ]) release}" = mkIf (if elem release [ "26.05" ] then nixosConfig.services.desktopManager.gnome.enable else nixosConfig.services.xserver.desktopManager.gnome.enable) {
			home.packages = [];
		};
		"25.11" = mkIf nixosConfig.services.desktopManager.gnome.enable {
			home.packages = [];
		};
	}."${release}" or (throw "Release is not implemented: ${release}")

	{
		# FIXME(Krey): Move this to the extension management
		home.packages = [
			pkgs.gnome-decoder # QR Code Management

			# Include the expected extensions
				pkgs.gnomeExtensions.removable-drive-menu
				pkgs.gnomeExtensions.vitals
				pkgs.gnomeExtensions.blur-my-shell
				pkgs.gnomeExtensions.gsconnect
				pkgs.gnomeExtensions.desktop-cube
				pkgs.gnomeExtensions.burn-my-windows
				pkgs.gnomeExtensions.caffeine
				pkgs.gnomeExtensions.space-bar
		];
	}
]
