{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.web-browsers-kreyren.imports = [
		homeManagerModules.web-browsers-firefox-kreyren
	];

	imports = [
		./firefox
	];
}
