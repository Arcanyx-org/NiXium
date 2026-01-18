{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.prompts-kreyren.imports = [
		homeManagerModules.prompts-starship-kreyren
	];

	imports = [
		./starship
	];
}
