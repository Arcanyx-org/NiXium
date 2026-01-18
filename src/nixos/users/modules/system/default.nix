{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.system.imports = [
		homeManagerModules.system-nix
	];

	imports = [
		./nix
	];
}
