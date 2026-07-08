{ config, lib, pkgs, nixosConfig,... }:

# Kira's management of KODI-related packages that are needed to make GNOME to run well

# FIXME-DOCS(Krey): This file is getting complicated, document what packages are needed for what version and what reason

let
	inherit (lib) mkIf mkMerge elem optionalString;
	inherit (lib.trivial) release;
in mkIf nixosConfig.services.xserver.desktopManager.kodi.enable (mkMerge [
	{
		"${optionalString (elem release [ "23.11" "24.05" "24.11" "25.05" "25.11" "26.05" ]) release}" = {
			home.packages = [];
		};
	}."${release}" or (throw "Release is not implemented: ${release}")

	{
		home.packages = [];
	}
])
