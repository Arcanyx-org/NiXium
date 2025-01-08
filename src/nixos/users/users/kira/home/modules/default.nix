{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.modules-kira.imports = [
		homeManagerModules.system-kira
	];

	imports = [
		./system
	];
}
