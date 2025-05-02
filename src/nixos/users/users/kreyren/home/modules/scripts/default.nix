{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.scripts-kreyren.imports = [
		homeManagerModules.scripts-mpv-kreyren
		homeManagerModules.scripts-ssh-kreyren
		homeManagerModules.scripts-wake-kreyren
		homeManagerModules.scripts-unrar-kreyren
	];

	imports = [
		./mpv
		./ssh
		./unrar
		./wake
	];
}
