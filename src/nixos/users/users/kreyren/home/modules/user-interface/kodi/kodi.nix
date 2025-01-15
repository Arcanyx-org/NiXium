{ config, lib, pkgs, nixosConfig,... }:

# Temporary research file

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
		programs.kodi.addonSettings = {
			plugin.program.steam.library = {
				# steam-id = "";
				# steam-key = "";
				steam-exe = "${config.programs.steam.package.outPath}/bin/steam";
				# FIXME-QA(Krey): This should be set in a less stupid way e.g. using programs.steam.something
				steam-path = "${config.home.homeDirectory}/.local/share/Steam";
			};
		};
	}
])
