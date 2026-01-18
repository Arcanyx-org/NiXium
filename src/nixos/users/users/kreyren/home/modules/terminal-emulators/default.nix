{ config, ... }:

let
	inherit (config.flake) homeManagerModules;
in {
	flake.homeManagerModules.terminal-emulators-kreyren.imports = [
		homeManagerModules.terminal-emulators-alacritty-kreyren
	];

	imports = [
		./alacritty
	];
}
