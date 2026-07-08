{ lib, nixosConfig,... }:

# Kreyren's management of KODI-related packages that are needed to make GNOME to run well

let
	inherit (lib) elem optionalString mkIf mkMerge;
	inherit (lib.trivial) release;
in mkIf nixosConfig.services.xserver.desktopManager.kodi.enable (mkMerge [
	{
		"${optionalString (elem release [ "24.05" "24.11" "25.05" "25.11" "26.05" ]) release}" = {
			home.packages = [];
		};
	}."${release}" or (throw "Release is not implemented: ${release}")

	{
		home.packages = [];
	}
])
