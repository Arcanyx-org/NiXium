{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.scripts-wake-kreyren.imports = [
		homeManagerModules.scripts-wake-morph-kreyren
	];

	imports = [
		./morph
	];
}
