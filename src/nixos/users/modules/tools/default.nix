{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.tools.imports = [
		homeManagerModules.tools-direnv
		homeManagerModules.tools-git
	];

	imports = [
		./direnv
		./git
	];
}
