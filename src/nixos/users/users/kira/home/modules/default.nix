{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.modules-kira.imports = [
		homeManagerModules.system-kira
		homeManagerModules.ui-kira
	];

	imports = [
		./system
		./user-interface
	];
}
