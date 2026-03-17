{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.programs.imports = [
		homeManagerModules.programs-appimage
	];

	imports = [
		./appimage
	];
}
