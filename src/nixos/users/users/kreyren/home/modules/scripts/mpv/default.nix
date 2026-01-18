{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.scripts-mpv-kreyren.imports = [
		homeManagerModules.scripts-mpv-krey
	];

	imports = [
		./krey
	];
}
