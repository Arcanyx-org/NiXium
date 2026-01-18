{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.apps-kreyren.imports = [
		homeManagerModules.apps-bottles-kreyren
	];

	imports = [
		./bottles
	];
}
