{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.tools.imports = [
		homeManagerModules.tools-direnv
		homeManagerModules.tools-git
		homeManagerModules.tools-proprietary
	];

	imports = [
		./direnv
		./git
		./proprietary
	];
}
