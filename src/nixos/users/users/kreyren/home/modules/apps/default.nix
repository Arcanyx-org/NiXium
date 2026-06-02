{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.apps-kreyren.imports = [
		homeManagerModules.apps-bottles-kreyren
		homeManagerModules.apps-opencode-kreyren
	];

	imports = [
		./bottles
		./opencode
	];
}
