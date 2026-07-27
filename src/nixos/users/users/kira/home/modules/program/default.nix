{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.program-kira.imports = [
		homeManagerModules.program-steam-kira
	];

	imports = [
		./steam
	];
}
