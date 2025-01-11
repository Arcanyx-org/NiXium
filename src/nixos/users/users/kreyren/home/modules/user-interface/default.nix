{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.ui-kreyren.imports = [
		homeManagerModules.ui-gnome-kreyren
		homeManagerModules.ui-kodi-kreyren
	];

	imports = [
		./gnome
		./kodi
	];
}
