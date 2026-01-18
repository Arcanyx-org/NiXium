{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.system-kira.imports = [
		homeManagerModules.system-impermanence-kira
		# homeManagerModules.system-pac-kira
	];

	imports = [
		./impermanence
		./pac
	];
}
