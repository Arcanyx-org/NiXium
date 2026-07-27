{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.tools-kira.imports = [
		homeManagerModules.tools-ragenix-kira
	];

	imports = [
		./ragenix
	];
}
