{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.system.imports = [
		homeManagerModules.system-flatpak
		homeManagerModules.system-impermanence
		homeManagerModules.system-nix
	];

	imports = [
		./flatpak
		./impermanence
		./nix
	];
}
