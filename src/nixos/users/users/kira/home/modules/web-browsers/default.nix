{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.web-browsers-kira.imports = [
		homeManagerModules.web-browsers-firefox-kira
	];

	imports = [
		./firefox
	];
}
