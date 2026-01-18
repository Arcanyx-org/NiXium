{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.shells-kreyren.imports = [
		homeManagerModules.shells-bash-kreyren
		homeManagerModules.shells-nushell-kreyren
	];

	imports = [
		./bash
		./nushell
	];
}
