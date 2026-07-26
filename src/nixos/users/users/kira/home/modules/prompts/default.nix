{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.prompts-kira.imports = [
		homeManagerModules.prompts-starship-kira
	];

	imports = [
		./starship
	];
}
