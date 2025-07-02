{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.scripts-kreyren.imports = [
		homeManagerModules.scripts-mozajk-kreyren
		homeManagerModules.scripts-mpv-kreyren
		homeManagerModules.scripts-ssh-kreyren
		homeManagerModules.scripts-wake-kreyren
		homeManagerModules.scripts-unrar-kreyren
	];

	imports = [
		./mozajk
		./mpv
		./ssh
		./unrar
		./wake
	];
}
