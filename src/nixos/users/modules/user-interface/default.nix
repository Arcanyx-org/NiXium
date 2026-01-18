{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.ui.imports = [
		homeManagerModules.ui-gnome
	];

	imports = [
		./gnome
	];
}
