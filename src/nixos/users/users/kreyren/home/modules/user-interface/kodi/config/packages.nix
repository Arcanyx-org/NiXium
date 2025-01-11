{ config, lib, pkgs, nixosConfig,... }:

# Kreyren's management of KODI-related packages that are needed to make GNOME to run well

# FIXME-DOCS(Krey): This file is getting complicated, document what packages are needed for what version and what reason

let
	inherit (lib) mkIf mkMerge;
in mkIf nixosConfig.services.xserver.desktopManager.kodi.enable (mkMerge [
	{
		"23.11" = {
			home.packages = [];
		};
		"24.05" = {
			home.packages = [];
		};
		"24.11" = {
			home.packages = [];
		};
		# FIXME-QA(Krey): Duplicate Code
		"25.05" = {
			home.packages = [];
		};
	}."${lib.trivial.release}" or (throw "Release is not implemented: ${lib.trivial.release}")

	{
		home.packages = [];
	}
])
