{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.ui-kira.imports = [
		homeManagerModules.ui-gnome-kira
		homeManagerModules.ui-kodi-kira
	];

	imports = [
		./gnome
		./kodi
	];
}
