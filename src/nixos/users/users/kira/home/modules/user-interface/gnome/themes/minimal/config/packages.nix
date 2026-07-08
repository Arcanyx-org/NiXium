{ config, lib, pkgs, nixosConfig,... }:

# Management of needed packages for Kira's Generic GNOME Theme

let
	inherit (lib) elem mkIf mkMerge;
	inherit (lib.trivial) release;
in mkIf (if elem release [ "26.05" ] then nixosConfig.services.desktopManager.gnome.enable else nixosConfig.services.xserver.desktopManager.gnome.enable) (mkMerge [
	{
		"24.05" = {
			home.packages = [];
		};
		"24.11" = {
			home.packages = [];
		};
	}."${lib.trivial.release}" or (throw "Release is not implemented: ${lib.trivial.release}")

	{
		home.packages = [];
	}
])
