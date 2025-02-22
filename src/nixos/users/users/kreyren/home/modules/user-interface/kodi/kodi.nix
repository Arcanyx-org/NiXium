{ config, lib, pkgs, nixosConfig,... }:

# Temporary research file

# FIXME-DOCS(Krey): This file is getting complicated, document what packages are needed for what version and what reason

let
	inherit (lib) mkIf mkMerge;
	inherit (builtins) toString;
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
		programs.kodi.enable = true;
		# WORKAROUND(Krey): Trying to set this via `programs.kodi.addonSettings` causes issues as the skin seems to explicitly require the type declaration
			home.file.kodi-entuary = {
				target = ".kodi/userdata/addon_data/skin.estuary/settings.xml";
				text = builtins.concatStringsSep "\n" [
					"<settings>"
						"<setting id=\"touchmode\" type=\"bool\">true</setting>"
					"</settings>"
				];
			};
		programs.kodi.addonSettings = {
			# Disable automatic version checks
				# FIXME(Krey): Should be forced false for all users due to purity
				"service.xbmc.versioncheck" = {
					versioncheck_enable = "false";
					upgrade_system = "false";
					upgrade_apt = "false";
				};
			"plugin.program.steam.library" = {
				# steam-id = "";
				# steam-key = "";
				steam-exe = "${nixosConfig.programs.steam.package.outPath}/bin/steam";
				# FIXME-QA(Krey): This should be set in a less stupid way e.g. using programs.steam.something
				steam-path = "${config.home.homeDirectory}/.local/share/Steam";
			};
		};
		programs.kodi.package = pkgs.kodi.withPackages (exts: [
			exts.steam-library
		]);
	}
])
