{ lib, nixosConfig,... }:

# Management of needed packages for Krey's Generic GNOME Theme

let
	inherit (lib) elem optionalString mkIf mkMerge;
	inherit (lib.trivial) release;
in mkMerge [
	{
		"${optionalString (elem release [ "24.05" "24.11" "25.05" ]) release}" = mkIf nixosConfig.services.xserver.desktopManager.gnome.enable {
			home.packages = [];
		};
		"25.11" = mkIf nixosConfig.services.desktopManager.gnome.enable {
			home.packages = [];
		};
	}."${release}"
]
